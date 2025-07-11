<?php

namespace App\Controller;

use Doctrine\DBAL\Connection;
use Psr\Cache\CacheItemPoolInterface;
use Psr\Log\LoggerInterface;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Attribute\Route;
use Throwable;

final class HealthCheckController
{
    public function __construct(
        private readonly Connection $connection,
        private readonly CacheItemPoolInterface $cache,
        private readonly LoggerInterface $logger
    ) {}

    #[Route('/healthcheck', name: 'app_healthcheck')]
    public function healthcheck(): JsonResponse
    {
        $dbStatus = $this->checkDbConnection();
        $cacheStatus = $this->checkCache();
        $status = $dbStatus && $cacheStatus ? Response::HTTP_OK : Response::HTTP_SERVICE_UNAVAILABLE;
        return new JsonResponse([
            'app' => true,
            'db' => $dbStatus,
            'cache' => $cacheStatus
        ], $status);
    }

    private function checkDbConnection(): bool
    {
        try {
            return $this->connection->connect();
        } catch (Throwable $e) {
            $this->logger->error('Health check DB failed', ['exception' => $e]);
            return false;
        }
    }

    private function checkCache(): bool
    {
        try {
            $item = $this->cache->getItem('healthcheck');
            $item->set('ok')->expiresAfter(30);
            $this->cache->save($item);

            return true;
        } catch (Throwable $e) {
            $this->logger->error('Health check cache failed', ['exception' => $e]);
            return false;
        }
    }
}
