import mido
import sys
import json

def get_midi_info(file_path):
    try:
        mid = mido.MidiFile(file_path)
        duration = mid.length
        
        # 전체 길이를 10개 구간으로 나눔 (예: 150초면 15초 단위)
        intervals = 10
        step = duration / intervals
        
        harmony_scores = []
        labels = []
        
        for i in range(intervals + 1):
            current_time = i * step
            # 실제로는 이 시간대의 노트를 분석해야 하지만, 
            # 우선 구조를 잡기 위해 시간(초)과 시뮬레이션 점수를 생성합니다.
            labels.append(round(current_time, 1)) 
            
            # 테스트용 점수 생성 로직 (나중에 실제 분석 로직으로 대체)
            score = 100 - (i * 2) if i < 5 else 70 + (i * 3)
            harmony_scores.append(min(score, 100))

        return {
            "status": "success",
            "bpm": 120, # 기존 로직
            "duration": round(duration, 2),
            "tracks": len(mid.tracks),
            "harmony_scores": harmony_scores,
            "timeline_labels": labels # 시간 축 데이터를 추가로 보냄
        }
    except Exception as e:
        return {"status": "error", "message": str(e)}

if __name__ == "__main__":
    print(json.dumps(get_midi_info(sys.argv[1])))