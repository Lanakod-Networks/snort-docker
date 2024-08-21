import {NextApiRequest, NextApiResponse} from "next";
import * as fs from "node:fs";
import csvtojson from 'csvtojson';

// // get the incoming request URL, e.g. 'posts?limit=10&offset=0&order=id.asc'
// const requestUrl = req.url?.substring("/api/admin/".length);
// // build the CRUD request based on the incoming request
// const url = `${process.env.SUPABASE_URL}/rest/v1/${requestUrl}`;
// const options: RequestInit = {
//     method: req.method,
//     headers: {
//         prefer: req.headers["prefer"] as string ?? "",
//         accept: req.headers["accept"] ?? "application/json",
//         ["content-type"]: req.headers["content-type"] ?? "application/json",
//     },
// };
// if (req.body) {
//     options.body = JSON.stringify(req.body);
// }
// // call the CRUD API
// const response = await fetch(url, options);
// // send the response back to the client
// const contentRange = response.headers.get("content-range");
// if (contentRange) {
//     res.setHeader("Content-Range", contentRange);
// }
// res.end(await response.text());

export default async function handler(req: NextApiRequest, res: NextApiResponse) {
    const logs = fs.readFileSync('/var/log/snort/alert_csv.txt', 'utf-8')
    const csvHeaders = 'timestamp,2,protocol,4,5,6,from,to,9,action\n'
    const pagination = req.body.pagination as {page: number, perPage: number}
    try {
        csvtojson()
            .fromString(csvHeaders + logs)
            .then(data => {
                const idData = data.map((e,i) => {
                    return {
                        id: i + 1,
                        ...e,
                    }
                })
                if(pagination.page === 1) {
                    idData.splice(pagination.perPage, idData.length - pagination.perPage)
                } else {
                    idData.splice(0, pagination.perPage * (pagination.page - 1))
                    idData.splice(pagination.perPage, idData.length - pagination.perPage)
                }
                return {logs: idData, length: data.length}
            })
            .then((jsonArrayObj: any) => {
                res.end(JSON.stringify({
                    logs: jsonArrayObj.logs,
                    length: jsonArrayObj.length,
                }));
            })
    } catch (error) {
        console.log(error)
        res.end(JSON.stringify({
            logs: [],
            length: 0
        }));
    }
}