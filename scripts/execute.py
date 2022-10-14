import os.path
import websockets
import subprocess
import asyncio

information = "Running tests before compiling..."

print(f"{information} [0/2]")

if os.path.exists(os.environ["MOON_PATH"]):
    print(f"{information} [1/2]")
    # print(os.environ["MOON_PATH"])
else:
    print("FAILURE: Failed to find moonc executable! Make sure your path is correct.")
    exit(FileExistsError)

if os.path.exists(os.environ["FILE_PATH"]):
    print(f"{information} [2/2]")
    # print(os.environ["FILE_PATH"])
else:
    print("FAILURE: Failed to find library file! Make sure your path is correct.")
    exit(FileExistsError)

print("Compiling...")

real_moon_path = os.path.abspath(os.environ["MOON_PATH"])
real_file_path = os.path.abspath(os.environ["FILE_PATH"])

return_code = subprocess.run([real_moon_path, real_file_path])

compiled_path = real_file_path.replace(".moon", ".lua")

async def execute():
    content = ""
    file_handle = open(compiled_path)

    for line in file_handle.readlines():
        content += line

    file_handle.close()

    print("Executing script")

    async with websockets.connect("ws://localhost:24892/execute") as websocket:
        await websocket.send(content)

        await websocket.close()

    print("Executed script!")

if os.path.exists(compiled_path):
    if os.environ["EXECUTE"] == "true":
        asyncio.run(execute())

else:
    print("FAILURE: Compiled path seems to be different from moon path?")
