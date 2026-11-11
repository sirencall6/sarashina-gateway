import httpx
from fastapi import FastAPI, Request
from fastapi.responses import StreamingResponse, Response

app = FastAPI()
TARGET_URL = "https://api.sarashina.ai/v1/chat/completions"

@app.post("/v1/chat/completions")
async def chat_completions(request: Request):
    body = await request.json()

    # 1. 邪魔なパラメータを消去
    body.pop("stream_options", None)
    body.pop("logprobs", None)
    if "max_tokens" in body:
        body["max_completion_tokens"] = body.pop("max_tokens")

    req_headers = {
        "Authorization": request.headers.get("Authorization", ""),
        "Content-Type": "application/json"
    }

    if body.get("stream", False):
        async def stream_generator():
            try:
                async with httpx.AsyncClient(timeout=httpx.Timeout(600.0)) as client:
                    async with client.stream("POST", TARGET_URL, json=body, headers=req_headers) as response:
                        if response.status_code != 200:
                            yield await response.aread()
                            return
                        
                        try:
                            # 2. 加工や細工を一切せず、生のデータを光の速さで右から左へ流す
                            async for chunk in response.aiter_raw():
                                if chunk:
                                    yield chunk
                        except BaseException:
                            pass
            except BaseException:
                pass
            
            # 3. 万が一Sarashinaが終了合図を忘れた時のための安全装置
            yield b"\n\ndata: [DONE]\n\n"

        return StreamingResponse(
            stream_generator(), 
            media_type="text/event-stream",
            # 【ここが最重要】通信が終わったら管を使い回さず「閉じる」ようVSCodeに指示する。
            # これにより「Premature close」の誤検知をシステムレベルで完全に封じます。
            headers={"Connection": "close"}
        )
    else:
        async with httpx.AsyncClient(timeout=httpx.Timeout(600.0)) as client:
            resp = await client.post(TARGET_URL, json=body, headers=req_headers)
            return Response(
                content=resp.content, 
                status_code=resp.status_code, 
                headers={"Content-Type": "application/json"}
            )

if __name__ == "__main__":
    import uvicorn
    print("==================================================")
    print(" Sarashina 中継サーバー（Connection: close 対策版）起動")
    print(" ※ 終了するには [Ctrl + C] を押してください")
    print("==================================================")
    try:
        # ローカルホスト (127.0.0.1) のポート 8000 でプロキシサーバーを起動
        uvicorn.run(app, host="127.0.0.1", port=8000)
    except KeyboardInterrupt:
        print("\n[Ctrl + C] を検知しました。サーバーを終了しました。")
