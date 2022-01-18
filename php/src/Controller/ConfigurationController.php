<?php

namespace AIO\Controller;

use AIO\ContainerDefinitionFetcher;
use AIO\Data\ConfigurationManager;
use AIO\Data\InvalidSettingConfigurationException;
use AIO\Docker\DockerActionManager;
use Psr\Http\Message\ResponseInterface as Response;
use Psr\Http\Message\ServerRequestInterface as Request;

class ConfigurationController
{
    private ConfigurationManager $configurationManager;

    public function __construct(
        ConfigurationManager $configurationManager
    ) {
        $this->configurationManager = $configurationManager;
    }

    public function SetConfig(Request $request, Response $response, $args) : Response {
        try {
            if (isset($request->getParsedBody()['domain'])) {
                $this->configurationManager->SetDomain($request->getParsedBody()['domain']);
            }

            if (isset($request->getParsedBody()['borg_backup_host_location'])) {
                $this->configurationManager->SetBorgBackupHostLocation($request->getParsedBody()['borg_backup_host_location']);
            }

            return $response->withStatus(201)->withHeader('Location', '/');
        } catch (InvalidSettingConfigurationException $ex) {
            $response->getBody()->write($ex->getMessage());
            return $response->withStatus(422);
        }
    }
}
