import {
    CreateParams, DeleteManyParams,
    DeleteParams,
    fetchUtils,
    GetListParams,
    GetManyParams,
    GetManyReferenceParams,
    GetOneParams, UpdateManyParams,
    UpdateParams,
} from "react-admin";
import { stringify } from "query-string";

const apiUrl = "http://localhost:3000/api/admin";
const httpClient = fetchUtils.fetchJson;

export const adminDataProvider = {
    getList: async (resource: string, params: GetListParams) => {
        const {headers, json} = await httpClient(apiUrl, {
            method: "POST",
            body: JSON.stringify(params),
        });
        return {
            data: json.logs,
            total: json.length,
        };
    },
    delete: async (resource: string, params: DeleteParams) => {
        const {headers, json} = await httpClient(apiUrl);
        return {
            data: json.events,
            total: json.events.length,
        };
    },
    getOne: async (resource: string, params: GetOneParams) => {
        const {headers, json} = await httpClient(apiUrl);
        return {
            data: json.events,
            total: json.events.length,
        };
    },
    update: async (resource: string, params: UpdateParams) => {
        const {headers, json} = await httpClient(apiUrl);
        return {
            data: json.events,
            total: json.events.length,
        };},
    getMany: async (resource: string, params: GetManyParams) => {
        const {headers, json} = await httpClient(apiUrl);
        return {
            data: json.events,
            total: json.events.length,
        };},
    getManyReference: async (resource: string, params: GetManyReferenceParams) => {
        let result0 = await httpClient(apiUrl);
        const {headers, json} = result0;
        return {
            data: json.events,
            total: json.events.length,
        };
    },
    create: async (resource: string, params: CreateParams) => {
        const {headers, json} = await httpClient(apiUrl);
        return {
            data: json.events,
            total: json.events.length,
        };},
    updateMany: async (resource: string, params: UpdateManyParams) => {
        const {headers, json} = await httpClient(apiUrl);
        return {
            data: json.events,
            total: json.events.length,
        };},
    deleteMany: async (resource: string, params: DeleteManyParams) => {
        const {headers, json} = await httpClient(apiUrl);
        return {
            data: json.events,
            total: json.events.length,
        };
    }
};