<?php

namespace App\Controller;

use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\Routing\Annotation\Route;

class HealthCheckController
{
    #[Route(path: '/healthcheck', name: 'healthcheck')]
    public function healthcheck(): JsonResponse
    {
        return new JsonResponse([
            'app' => true,
            'db' => $this->checkDbConnection(),
            'cache' => $this->checkCache()
        ]);
    }

    private function checkDbConnection(): bool
    {
        return true;
    }

    private function checkCache(): bool
    {
        return true;
    }
}

