<?php
if ($_SERVER['REQUEST_URI'] === '/health') {
    header('Content-Type: text/plain; version=0.0.4');

$method = $_SERVER['REQUEST_METHOD'];
    $endpoint = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH) ?: '/';
    $code = http_response_code() ?: 200;

    // 1. Базовые метрики приложения
    echo "# HELP app_info Application information\n";
    echo "# TYPE app_info gauge\n";
    echo 'app_info{app="app1",version="1.0",env="production"} 1' . PHP_EOL;

    echo "# HELP app_health Application health status\n";
    echo "# TYPE app_health gauge\n";
    echo 'app_health 1' . PHP_EOL;

    // 2. HTTP метрики (упрощенные)
    echo "# HELP http_requests_total Total HTTP requests\n";
    echo "# TYPE http_requests_total counter\n";
    echo 'http_requests_total{method="' . $method . '",endpoint="' . $endpoint . '",code="' . $code . '"} 1' . PHP_EOL;

    // 3. Время ответа (простой gauge вместо histogram)
    $response_time = 0.05; // примерное значение в секундах
    echo "# HELP http_response_time_seconds HTTP response time\n";
    echo "# TYPE http_response_time_seconds gauge\n";
    echo 'http_response_time_seconds ' . $response_time . PHP_EOL;

    // 4. Активные пользователи (примерное значение)
    $active_users = rand(10, 50);
    echo "# HELP active_users Active users count\n";
    echo "# TYPE active_users gauge\n";
    echo 'active_users ' . $active_users . PHP_EOL;

    // 5. Cache метрики (упрощенные)
    $cache_hits = rand(70, 90);
    $cache_misses = rand(10, 30);

    echo "# HELP cache_hits_total Total cache hits\n";
    echo "# TYPE cache_hits_total counter\n";
    echo 'cache_hits_total ' . $cache_hits . PHP_EOL;

    echo "# HELP cache_misses_total Total cache misses\n";
    echo "# TYPE cache_misses_total counter\n";
    echo 'cache_misses_total ' . $cache_misses . PHP_EOL;

    // 6. Системные метрики
    echo "# HELP php_memory_usage_bytes PHP memory usage\n";
    echo "# TYPE php_memory_usage_bytes gauge\n";
    echo 'php_memory_usage_bytes ' . memory_get_usage(true) . PHP_EOL;

    echo "# HELP php_version PHP version info\n";
    echo "# TYPE php_version gauge\n";
    echo 'php_version{version="' . phpversion() . '"} 1' . PHP_EOL;

    echo "# HELP app_uptime_seconds Application uptime\n";
    echo "# TYPE app_uptime_seconds gauge\n";
    // Если нужно реальное время - можно сохранять время старта в файл
    echo 'app_uptime_seconds ' . time() . PHP_EOL;

    exit;
}

// Получаем текущее время и IP адрес
$current_time = date('Y-m-d H:i:s');
$server_ip = $_SERVER['SERVER_ADDR'] ?? 'Unknown';
$hostname = gethostname() ?: 'Unknown';
?>
<!DOCTYPE html>
<html>
<head>
    <title>My PHP App</title>
    <style>
        body { font-family: Times New Roman, sans-serif; margin: 40px; }
        .info { background: #f5f5f5; padding: 15px; border-radius: 5px; margin: 20px 0; }
    </style>
</head>
<body>
    <h1>Hello from PHP!</h1>
    <p>This is a simple test application owner Andrey Gurenich with configured Apache for health app status. Using webhook Jenkins v2</p>

    <div class="info">
        <h3>Server Information:</h3>
        <p><strong>Current Time:</strong> <?php echo $current_time; ?></p>
        <p><strong>Server IP:</strong> <?php echo $server_ip; ?></p>
        <p><strong>Hostname:</strong> <?php echo $hostname; ?></p>
    </div>
</body>
</html>
