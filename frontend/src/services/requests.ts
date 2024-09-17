export type JsonType = boolean | number | string | null | JsonType[] | { [key: string]: JsonType };

export type HttpMethod =
    | 'GET'
    | 'HEAD'
    | 'POST'
    | 'PUT'
    | 'DELETE'
    | 'CONNECT'
    | 'OPTIONS'
    | 'TRACE'
    | 'PATCH';

export type RequestOptions = {
    params?: { [key: string]: any } | undefined;
    headers?: HeadersInit;
    json?: boolean;
    body?: BodyInit | JsonType | null;
};

export type FetchResponse = {
    response: Promise<Response>;
    cancel: () => void;
};

export type FetchResponseValue<T> = {
    data: Promise<T>;
    cancel: () => void;
};

export async function handleErrorResponses(response: Response): Promise<Response> {
    if (response.ok) return response;

    let data: JsonType | undefined;

    try {
        data = await response.clone().json();
    } catch (error) {
        data = undefined;
    }

    throw new ResponseError(response, data);
}

export function normalizeAbortError(error: any) {
    if (error instanceof DOMException && error.name === 'AbortError') {
        throw new RequestCancelled(error.message);
    }

    throw error;
}

export class ResponseError extends Error {
    public response: Response;
    public data: JsonType | undefined;

    constructor(response: Response, data: JsonType | undefined) {
        super(response.statusText);

        this.response = response;
        this.data = data;
    }
}

export class RequestCancelled extends Error {}

export function request(
    method: HttpMethod,
    url: URL | string,
    options: RequestOptions & { json: false; body?: BodyInit }
): FetchResponse;
export function request(
    method: HttpMethod,
    url: URL | string,
    options?: RequestOptions & { json?: true; body?: JsonType }
): FetchResponse;
export function request(
    method: HttpMethod,
    url: URL | string,
    options: RequestOptions = {}
): FetchResponse {
    const { body, params, headers, json = true } = options;

    const abortController = new AbortController();

    if (typeof url === 'string') {
        url = new URL(url);
    }

    Object.entries(params ?? {}).forEach(([key, value]) => {
        if (value !== undefined) {
            url.searchParams.set(key, value);
        }
    });

    const response = window
        .fetch(url, {
            method,
            headers: {
                ...(json ? { 'Content-Type': 'application/json' } : {}),
                ...headers,
            },
            body: json ? JSON.stringify(body) : (body as BodyInit | undefined),
            signal: abortController.signal,
        })
        .then(handleErrorResponses)
        .catch(normalizeAbortError);

    return { response: response as Promise<Response>, cancel: () => abortController.abort() };
}
