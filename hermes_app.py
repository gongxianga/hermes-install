import webview
import subprocess
import threading
import socket
import time
import sys
import os

HERMES_PORT = 9119
HERMES_URL = f"http://127.0.0.1:{HERMES_PORT}"

hermes_process = None

LOADING_HTML = """
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body {
    background: #1e1e3c;
    color: white;
    font-family: 'Segoe UI', sans-serif;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    height: 100vh;
  }
  h1 { font-size: 2rem; margin-bottom: 12px; }
  p  { font-size: 1rem; color: #aaa; margin-bottom: 32px; }
  .spinner {
    width: 48px; height: 48px;
    border: 5px solid #444;
    border-top-color: #7c6cf0;
    border-radius: 50%;
    animation: spin 0.9s linear infinite;
  }
  @keyframes spin { to { transform: rotate(360deg); } }
  #status { margin-top: 20px; font-size: 0.9rem; color: #888; }
</style>
</head>
<body>
  <h1>Hermes Agent</h1>
  <p>正在启动，请稍候...</p>
  <div class="spinner"></div>
  <div id="status">启动中...</div>
</body>
</html>
"""

ERROR_HTML = """
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<style>
  * {{ margin: 0; padding: 0; box-sizing: border-box; }}
  body {{
    background: #1e1e3c;
    color: white;
    font-family: 'Segoe UI', sans-serif;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: center;
    height: 100vh;
    text-align: center;
    padding: 40px;
  }}
  h1 {{ font-size: 1.6rem; color: #ff6b6b; margin-bottom: 16px; }}
  p  {{ font-size: 0.95rem; color: #aaa; margin-bottom: 8px; line-height: 1.6; }}
  code {{ background: #2a2a50; padding: 4px 10px; border-radius: 4px; font-size: 0.9rem; }}
  button {{
    margin-top: 28px;
    padding: 12px 32px;
    background: #7c6cf0;
    color: white;
    border: none;
    border-radius: 8px;
    font-size: 1rem;
    cursor: pointer;
  }}
  button:hover {{ background: #9a8ef5; }}
</style>
</head>
<body>
  <h1>启动失败</h1>
  <p>无法启动 Hermes dashboard。</p>
  <p>请确认已安装 Hermes 并运行过 <code>hermes setup</code></p>
  <p>如缺少依赖请在 PowerShell 运行：</p>
  <p><code>pip install "hermes-agent[web]"</code></p>
  <p style="margin-top:16px; color:#666;">错误信息：{error}</p>
  <button onclick="window.location.reload()">重试</button>
</body>
</html>
"""


def is_port_open(port, host="127.0.0.1"):
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
        s.settimeout(1)
        return s.connect_ex((host, port)) == 0


def start_hermes_dashboard():
    global hermes_process
    if is_port_open(HERMES_PORT):
        return True, None

    flags = 0
    if sys.platform == "win32":
        flags = subprocess.CREATE_NO_WINDOW

    try:
        hermes_process = subprocess.Popen(
            ["hermes", "dashboard", "--no-open"],
            creationflags=flags,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )
    except FileNotFoundError:
        return False, "找不到 hermes 命令，请确认已安装"

    for _ in range(30):
        time.sleep(1)
        if hermes_process.poll() is not None:
            _, err = hermes_process.communicate()
            return False, err.decode("utf-8", errors="replace")[:200]
        if is_port_open(HERMES_PORT):
            return True, None

    return False, "等待超时（30秒）"


def launch(window):
    ok, err = start_hermes_dashboard()
    if ok:
        window.load_url(HERMES_URL)
    else:
        window.load_html(ERROR_HTML.format(error=err or "未知错误"))


def main():
    window = webview.create_window(
        title="Hermes Agent",
        html=LOADING_HTML,
        width=1280,
        height=820,
        min_size=(800, 600),
    )

    def on_loaded():
        t = threading.Thread(target=launch, args=(window,), daemon=True)
        t.start()

    window.events.loaded += on_loaded
    webview.start()

    if hermes_process and hermes_process.poll() is None:
        hermes_process.terminate()


if __name__ == "__main__":
    main()
