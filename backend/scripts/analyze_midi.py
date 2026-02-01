import mido
import sys
import json

def get_midi_info(file_path):
    try:
        mid = mido.MidiFile(file_path)
        
        # BPM 추출 (기본값 120)
        tempo = 120
        for track in mid.tracks: # mid가 아니라 mid.tracks를 도는 것이 더 안전합니다.
            for msg in track:
                if msg.type == 'set_tempo':
                    tempo = mido.tempo2bpm(msg.tempo)
                    break # 첫 번째 템포 정보를 찾으면 중단
        
        return {
            "status": "success",
            "bpm": round(tempo, 2),
            "duration": round(mid.length, 2),
            "tracks": len(mid.tracks)
        }
    except Exception as e:
        # 에러 발생 시 상세 메시지 리턴
        return {"status": "error", "message": str(e)}

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(json.dumps({"status": "error", "message": "No file path provided"}))
        sys.exit(1)
        
    print(json.dumps(get_midi_info(sys.argv[1])))