import { fail } from "@sveltejs/kit";
import { writeFile } from "node:fs";
import type { Actions } from "./$types";

export const actions = {
    default: async ({ request }) => {
        const data = await request.formData();
        const name = data.get("name");
        const email = data.get("email");
        const startTime = data.get("start-time");
        const endTime = data.get("end-time");
        const temp = data.get("temp");

        const settings = {
            name,
            email,
            startTime: parseInt(startTime as string),
            endTime: parseInt(endTime as string),
            temp,
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
                startTime,
                endTime,
                temp,
            };
        } catch {
            return fail(400, {
                success: false,
                error: true,
                message: "something not right",
                name,
                email,
                startTime,
                endTime,
                temp,
            });
        }
    },
} satisfies Actions;
