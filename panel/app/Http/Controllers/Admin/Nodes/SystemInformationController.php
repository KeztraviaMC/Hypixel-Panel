<?php

namespace Pterodactyl\Http\Controllers\Admin\Nodes;

use Illuminate\Support\Str;
use Illuminate\Http\Request;
use Pterodactyl\Models\Node;
use Illuminate\Http\JsonResponse;
use Pterodactyl\Http\Controllers\Controller;
use Pterodactyl\Repositories\Wings\DaemonConfigurationRepository;

class SystemInformationController extends Controller
{
    /**
     * SystemInformationController constructor.
     */
    public function __construct(private DaemonConfigurationRepository $repository)
    {
    }

    /**
     * Returns system information from the Daemon.
     *
     * @throws \Pterodactyl\Exceptions\Http\Connection\DaemonConnectionException
     */
    public function __invoke(Request $request, Node $node): JsonResponse
    {
        $data = $this->repository->setNode($node)->getSystemInformation();

        return new JsonResponse([
            'version' => $data['version'] ?? '',
            'system' => [
                'type' => Str::title($data['os'] ?? 'Unknown'),
                'arch' => $data['architecture'] ?? '--',
                'release' => $data['kernel_version'] ?? '--',
                'hostname' => $data['hostname'] ?? '--',
                'uptime' => (int) ($data['uptime'] ?? 0),
                'cpus' => (int) ($data['cpu_count'] ?? 0),
                'cpu_model' => $data['cpu_model'] ?? '--',
                'cpu_speed_mhz' => (int) ($data['cpu_speed_mhz'] ?? 0),
                'memory' => $data['memory'] ?? ['total' => 0, 'used' => 0, 'free' => 0],
                'disk' => $data['disk'] ?? ['mount' => '/', 'total' => 0, 'used' => 0, 'free' => 0, 'type' => 'Unknown'],
            ],
        ]);
    }
}
