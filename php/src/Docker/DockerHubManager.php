<?php

namespace AIO\Docker;

use AIO\ContainerDefinitionFetcher;
use AIO\Data\ConfigurationManager;
use GuzzleHttp\Client;

class DockerHubManager
{
    private Client $guzzleClient;

    public function __construct()
    {
        $this->guzzleClient = new Client();
    }

    public function GetLatestDigestOfTag(string $name, string $tag) : ?string {
        $cacheKey = 'dockerhub-manifest-' . $name . $tag;

        $cachedVersion = apcu_fetch($cacheKey);
        if($cachedVersion !== false && is_string($cachedVersion)) {
            return $cachedVersion;
        }

        try {
            $authTokenRequest = $this->guzzleClient->request(
                'GET',
                'https://auth.docker.io/token?service=registry.docker.io&scope=repository:' . $name . ':pull'
            );
            $body = $authTokenRequest->getBody()->getContents();
            $decodedBody = json_decode($body, true);
            if(isset($decodedBody['token'])) {
                $authToken = $decodedBody['token'];
                $manifestRequest = $this->guzzleClient->request(
                    'GET',
                    'https://registry-1.docker.io/v2/'.$name.'/manifests/' . $tag,
                    [
                        'headers' => [
                            'Accept' => 'application/vnd.docker.distribution.manifest.v2+json',
                            'Authorization' => 'Bearer ' . $authToken,
                        ],
                    ]
                );
                $responseHeaders = $manifestRequest->getHeader('docker-content-digest');
                if(count($responseHeaders) === 1) {
                    $latestVersion = $responseHeaders[0];
                    apcu_add($cacheKey, $latestVersion, 600);
                    return $latestVersion;
                }
            }

            return null;
        } catch (\Exception $e) {
            return null;
        }
    }
}