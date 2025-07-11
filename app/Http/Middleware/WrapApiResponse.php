<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class WrapApiResponse
{
    /**
     * Handle an incoming request.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \Closure  $next
     * @return mixed
     */
    public function handle(Request $request, Closure $next)
    {
        $response = $next($request);

        if ($response->headers->get('Content-Type') === 'application/json' &&
            $response->getStatusCode() >= 200 &&
            $response->getStatusCode() < 300) {

            $data = $response->getData();

            if (!isset($data->data)) {
                $response->setData(['data' => $data]);
            }
        }

        return $response;
    }
}
