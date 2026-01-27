# ┌─── 1. Metadata & Description ──────────────────────────────────────────────┐
# │  [NAME] vid2txt (AI Transcriber)                                           │
# │  [INFO] Downloads media and transcribes it via local OpenAI Whisper.       │
# └────────────────────────────────────────────────────────────────────────────┘


# ┌─── 2. Configuration ───────────────────────────────────────────────────────┐

DEFAULT_MODEL="small"                           # [CFG] Standard model for balanced speed/accuracy
CPU_MODELS=("medium" "large")                   # [CFG] Models that trigger CPU fallback for VRAM safety
UI_COLOR_BORDER="%F{6}"                         # [CFG] Cyan border
UI_COLOR_TEXT="%F{15}"                          # [CFG] White values
UI_COLOR_LABEL="%B%F{12}"                       # [CFG] Bold blue labels


# ┌─── 3. Internal Helpers ────────────────────────────────────────────────────┐

_vid2txt_render_box() {
    local title="$1"                            # Source title
    local uploader="$2"                         # Channel name
    local target="$3"                           # Final filename

    # [OPT] Calculate dynamic width based on content (min 40, max 70)
    local max_w=40
    for str in "$title" "$uploader" "$target"; do (( ${#str} > max_w )) && max_w=${#str}; done
    (( max_w > 70 )) && max_w=70
    
    local hr_top="┌$(printf "─%.0s" {1..$((max_w + 12))})┐"
    local hr_bot="└$(printf "─%.0s" {1..$((max_w + 12))})┘"
    
    # [FLOW] Draw UI with smart truncation
    print -P "${UI_COLOR_BORDER}${hr_top}%f"
    print -P "${UI_COLOR_BORDER}│%f ${UI_COLOR_LABEL}Source:%f  ${UI_COLOR_TEXT}${title:0:$max_w}%f"
    print -P "${UI_COLOR_BORDER}│%f ${UI_COLOR_LABEL}Channel:%f ${UI_COLOR_TEXT}${uploader:0:$max_w}%f"
    print -P "${UI_COLOR_BORDER}│%f ${UI_COLOR_LABEL}Target:%f  ${UI_COLOR_TEXT}${target}%f"
    print -P "${UI_COLOR_BORDER}${hr_bot}%f"
}


# ┌─── 4. Core Logic (Main) ───────────────────────────────────────────────────┐

vid2txt() {
    # [FLOW] Pre-execution checks
    if [[ -z "$1" ]]; then print -P "%F{yellow}Usage: vid2txt <url_or_path> [model]"; return 1; fi
    
    # [FIX] Bypass potential aliases for core utilities
    local deps=("yt-dlp" "whisper" "ffmpeg" "md5sum");
    for cmd in $deps; do (( $+commands[$cmd] )) || { print -P "%F{red}Error: '$cmd' not found."; return 1; }; done

    local input_src="$1"
    local ai_model="${2:-$DEFAULT_MODEL}"
    local compute_device="cuda"
    local session_id="v2t_${RANDOM}"
    local tmp_audio="/tmp/${session_id}.wav"

    # [FLOW] Hardware capability routing
    for m in $CPU_MODELS; do [[ "$ai_model" == "$m"* ]] && compute_device="cpu"; done # [FIX] Prevent VRAM OOM

    # [FLOW] Fetch metadata and build naming
    local raw_title uploader
    if [[ "$input_src" =~ "^https?://" ]]; then
        local meta=("${(@f)$(yt-dlp --print "%(title)s" --print "%(uploader)s" "$input_src" 2>/dev/null)}")
        raw_title="${meta[1]:-Stream_${session_id}}"; uploader="${meta[2]:-Unknown}"
    else
        raw_title=$(basename "${input_src%.*}"); uploader="Local_Storage"
    fi

    # [OPT] Minimalist naming strategy: _[hash].txt
    local hash_id=$(echo -n "$input_src" | md5sum | cut -c1-7); local target_file="_${hash_id}.txt"

    # [FLOW] UI Entry Point
    echo ""; _vid2txt_render_box "$raw_title" "$uploader" "$target_file"; echo ""

    # [FLOW] Audio extraction pipeline
    if [[ "$input_src" =~ "^https?://" ]]; then
        yt-dlp -x --audio-format wav --postprocessor-args "-ar 16000 -ac 1" --output "$tmp_audio" --no-warnings --progress "$input_src"
    else
        ffmpeg -i "$input_src" -ar 16000 -ac 1 "$tmp_audio" -y -hide_banner -loglevel error
    fi
    [[ ! -f "$tmp_audio" ]] && { print -P "%F{9}[CRIT] Extraction failed.%f"; return 1; }

    # [FLOW] AI Transcription engine
    print -P "%F{13}[AI] Transcribing ($ai_model on $compute_device / FP32)...%f"
    
    # [FIX] FP16 False prevents 'NaN' errors on consumer-grade NVIDIA drivers
    whisper "$tmp_audio" --model "$ai_model" --device "$compute_device" --output_format "txt" --output_dir "/tmp" --verbose False --fp16 False

    # [FLOW] Finalization & Cleanup
    local gen_txt="/tmp/${session_id}.txt"; local fall_txt="/tmp/$(basename ${tmp_audio%.wav}).txt"; local target_path="./$target_file"

    if [[ -f "$gen_txt" ]]; then command mv "$gen_txt" "$target_path"
    elif [[ -f "$fall_txt" ]]; then command mv "$fall_txt" "$target_path"
    fi

    # [CRIT] Clean temporary artifacts (using command to bypass aliases like 'rip')
    command rm -f "$tmp_audio" "$fall_txt" "$gen_txt" 2>/dev/null

    if [[ -f "$target_path" ]]; then print -P "%F{10}[OK] Results saved to:%f $target_file"
    else print -P "%F{9}[CRIT] Process failed: Result file not found.%f"
    fi
}
