param([string]$CodeFile, [string]$Command = 'execute_code')
$ErrorActionPreference = 'Stop'
$params = @{}
if ($CodeFile) { $params.code = [IO.File]::ReadAllText((Resolve-Path -LiteralPath $CodeFile).Path) }
$request = @{type=$Command; params=$params} | ConvertTo-Json -Depth 8 -Compress
$client = [Net.Sockets.TcpClient]::new()
try {
    $client.Connect('127.0.0.1', 9876)
    $client.ReceiveTimeout = 600000
    $stream = $client.GetStream()
    $bytes = [Text.Encoding]::UTF8.GetBytes($request)
    $stream.Write($bytes, 0, $bytes.Length)
    $buffer = New-Object byte[] 65536
    $result = [Text.StringBuilder]::new()
    do {
        $count = $stream.Read($buffer, 0, $buffer.Length)
        if ($count -eq 0) { throw 'Blender closed the connection before returning JSON.' }
        [void]$result.Append([Text.Encoding]::UTF8.GetString($buffer, 0, $count))
        try { $parsed = $result.ToString() | ConvertFrom-Json; break } catch {}
    } while ($true)
    $result.ToString()
    if ($parsed.status -eq 'error') { throw $parsed.message }
} finally { $client.Dispose() }
