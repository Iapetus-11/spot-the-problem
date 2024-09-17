import { request, type FetchResponseValue } from '@/services/requests';

export type ProblemInfo = {
    category: string;
    description: string;
    answer: string;
    difficulty: number;
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
