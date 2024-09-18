import { request, type FetchResponseValue } from '@/services/requests';

export type ProblemInfo = {
    id: string;
    name: string;
    category: string;
    description: string;
    answer: string;
    difficulty: number;
    content: string;
};

export function listProblemSets(): FetchResponseValue<string[]> {
    const { response, cancel } = request(
        'GET',
        new URL('/api/problem_sets', window.location.origin)
    );

    return { data: response.then((res) => res.json()), cancel };
}

export function listProblems(problemSetName: string): FetchResponseValue<ProblemInfo[]> {
    const { response, cancel } = request(
        'GET',
        new URL(`/api/problem_sets/${problemSetName}`, window.location.origin)
    );

    return { data: response.then((res) => res.json()), cancel };
}

export function getProblem(
    problemSetName: string,
    problemId: string
): FetchResponseValue<ProblemInfo> {
    const { response, cancel } = request(
        'GET',
        new URL(`/api/problem_sets/${problemSetName}/${problemId}`, window.location.origin)
    );

    return { data: response.then((res) => res.json()), cancel };
}
