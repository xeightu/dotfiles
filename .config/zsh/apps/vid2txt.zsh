# ┌─── 1. Configuration ───────────────────────────────────────────────────────┐

DEFAULT_MODEL="small"
# [NOTE] Fallback to CPU for large models to avoid OOM on limited VRAM (GTX 1650)
CPU_MODELS=("medium" "large")

# Mocha-inspired UI Colors
UI_COLOR_BORDER="%F{111}"
UI_COLOR_TEXT="%F{15}"
UI_COLOR_LABEL="%B%F{183}"


# ┌─── 2. Internal Helpers ────────────────────────────────────────────────────┐

_vid2txt_render_box() {
    local _title="$1" _uploader="$2" _target="$3"
    local _max_w=40

    for _str in "$_title" "$_uploader" "$_target"; do 
        (( ${#_str} > _max_w )) && _max_w=${#_str}
    done

    (( _max_w > 70 )) && _max_w=70
    
    local _hr_top="┌$(printf "─%.0s" {1..$((_max_w + 12))})┐"
    local _hr_bot="└$(printf "─%.0s" {1..$((_max_w + 12))})┘"
    
    print -P "${UI_COLOR_BORDER}${_hr_top}%f"
    print -P "${UI_COLOR_BORDER}│%f ${UI_COLOR_LABEL}Source:%f  ${UI_COLOR_TEXT}${_title:0:$_max_w}%f"
    print -P "${UI_COLOR_BORDER}│%f ${UI_COLOR_LABEL}Channel:%f ${UI_COLOR_TEXT}${_uploader:0:$_max_w}%f"
    print -P "${UI_COLOR_BORDER}│%f ${UI_COLOR_LABEL}Target:%f  ${UI_COLOR_TEXT}${_target}%f"
    print -P "${UI_COLOR_BORDER}${_hr_bot}%f"
}


# ┌─── 3. Core Logic ──────────────────────────────────────────────────────────┐

vid2txt() {
    local _input_src="$1"
    local _ai_model="${2:-$DEFAULT_MODEL}"

    # Input validation
    if [[ -z "$_input_src" ]]; then
        print -nP "${UI_COLOR_BORDER}Input URL or Path > %f"
        read -r _input_src
        [[ -z "$_input_src" ]] && { print -P "%F{203}Cancelled.%f"; return 1; }
    fi

    # Dependency check
    local _deps=("yt-dlp" "whisper" "ffmpeg" "md5sum")
    for _cmd in $_deps; do 
        (( $+commands[$_cmd] )) || { print -P "%F{203}Error: '$_cmd' not found.%f"; return 1; }
    done

    # Device selection logic
    local _compute_device="cuda"
    for _m in $CPU_MODELS; do 
        [[ "$_ai_model" == "$_m"* ]] && _compute_device="cpu"
    done

    # Session initialization
    local _session_id="v2t_${RANDOM}"
    local _tmp_audio="/tmp/${_session_id}.wav"
    local _gen_txt="/tmp/${_session_id}.txt"
    local _fall_txt="/tmp/${_session_id}.wav.txt"

    # [FIX] Comprehensive cleanup on exit or interruption
    trap 'command rm -f "$_tmp_audio" "$_gen_txt" "$_fall_txt" 2>/dev/null' EXIT INT TERM

    # --- Phase 1: Metadata Acquisition ---
    local _raw_title _uploader
    if [[ "$_input_src" =~ "^https?://" ]]; then
        local _meta=("${(@f)$(yt-dlp --print "%(title)s" --print "%(uploader)s" "$_input_src" 2>/dev/null)}")
        _raw_title="${_meta[1]:-Stream_${_session_id}}"
        _uploader="${_meta[2]:-Unknown}"
    else
        _raw_title=$(basename "${_input_src%.*}")
        _uploader="Local_Storage"
    fi

    local _hash_id=$(echo -n "$_input_src" | md5sum | cut -c1-7)
    local _target_file="_${_hash_id}.txt"

    echo ""
    _vid2txt_render_box "$_raw_title" "$_uploader" "$_target_file"
    echo ""

    # --- Phase 2: Audio Extraction ---
    local _t_start _t_end
    _t_start=$(date +%s)
    print -P "%F{117}[1/3] Fetching video and extracting audio...%f"

    if [[ "$_input_src" =~ "^https?://" ]]; then
        yt-dlp -x --audio-format wav --postprocessor-args "-ar 16000 -ac 1" \
            --output "$_tmp_audio" --no-warnings --progress "$_input_src"
    else
        ffmpeg -i "$_input_src" -ar 16000 -ac 1 "$_tmp_audio" -y -hide_banner -loglevel error
    fi

    [[ ! -f "$_tmp_audio" ]] && { print -P "%F{203}[CRIT] Extraction failed.%f"; return 1; }
    
    _t_end=$(date +%s)
    print -P "%F{114}[OK] Audio ready (%f$((_t_end-_t_start))s%F{114}) → %f$_tmp_audio"

    # --- Phase 3: Transcription ---
    print -P "%F{117}[2/3] Transcribing with model '%F{183}$_ai_model%F{117}' on '%F{183}$_compute_device%F{117}'...%f"
    _t_start=$(date +%s)
    
    # [NOTE] FP16 disabled for better compatibility with diverse CUDA compute caps
    whisper "$_tmp_audio" --model "$_ai_model" --device "$_compute_device" \
            --output_format "txt" --output_dir "/tmp" --verbose False --fp16 False
    
    _t_end=$(date +%s)

    # --- Phase 4: Finalization ---
    local _target_path="./$_target_file"
    if [[ -f "$_gen_txt" ]]; then 
        command mv "$_gen_txt" "$_target_path"
    elif [[ -f "$_fall_txt" ]]; then 
        command mv "$_fall_txt" "$_target_path"
    fi

    if [[ -f "$_target_path" ]]; then
        local _size_kb=$(command du -k "$_target_path" | command cut -f1)
        local _duration_s=$(command ffprobe -i "$_tmp_audio" -show_entries format=duration -v quiet -of csv="p=0" | command cut -d. -f1)
        print -P "%F{114}[3/3] Saved → %B%F{183}$_target_file%f%b (%F{117}${_size_kb}KB%F{114}, audio ${_duration_s}s, %F{117}$((_t_end-_t_start))s%F{114} for ASR)"
    else
       print -P "%F{203}[CRIT] Process failed: Result file not found.%f"
    fi
}
