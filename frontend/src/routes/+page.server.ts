import { fail } from "@sveltejs/kit";
import { readFileSync, writeFile } from "node:fs";
import type { Actions, PageLoad } from "./$types";

export const load: PageLoad = async () => {
    try {
        const data = await readFileSync("settings.json", "utf8");
        console.log(data);
        const settings = JSON.parse(data);
        return { settings };
    } catch (e) {
        console.log("Err", e);
    }
};

export const actions = {
    default: async ({ request }) => {
        const data = await request.formData();
        const name = data.get("name");
        const email = data.get("email");
        const onContinually = data.get("on-continually");
        const startTime = data.get("start-time");
        const endTime = data.get("end-time");
        const temperature = data.get("temperature");

        const settings = {
            name,
            email,
            onContinually,
            startTime: parseInt(startTime as string),
            endTime: parseInt(endTime as string),
            temperature,
        };

        try {
            let settingsData = JSON.stringify(settings, null, 2);
            writeFile("settings.json", settingsData, (err: Error) => {
                if (err) throw err;
            });
            return {
                success: true,
                message: "",
                name,
                email,
                onContinually,
                startTime,
                endTime,
                temperature,
            };
        } catch {
            return fail(400, {
                success: false,
                error: true,
                message: "something not right",
                name,
                email,
                onContinually,
                startTime,
                endTime,
                temperature,
            });
        }
    },
} satisfies Actions;
