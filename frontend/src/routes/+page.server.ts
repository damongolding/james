import { fail } from "@sveltejs/kit";
// @ts-ignore
import { readFileSync, writeFileSync } from "node:fs";
import type { Actions, PageLoad } from "./$types";

export const load: PageLoad = async () => {
    try {
        const data = await readFileSync("settings.json", "utf8");
        const settings = JSON.parse(data);
        return { settings };
    } catch (e) {
        console.log("Err", e);
    }
};

export const actions = {
    default: async ({ request }) => {
        const data = await request.formData();
        const onContinually = data.get("on-continually");
        const startTime = data.get("start-time");
        const endTime = data.get("end-time");
        const useCelsius = data.get("use-celsius");

        const settings = {
            useCelsius: useCelsius == "true" ? true : false,
            onContinually: onContinually != null ? true : false,
            startTime: parseInt(startTime as string),
            endTime: parseInt(endTime as string),
        };

        console.log(settings);

        try {
            let settingsData = JSON.stringify(settings, null, 2);
            await writeFileSync("settings.json", settingsData);
            return {
                success: true,
                message: "",
                onContinually: settings.onContinually,
                startTime: settings.startTime,
                endTime: settings.endTime,
                useCelsius: settings.useCelsius,
            };
        } catch {
            return fail(400, {
                success: false,
                error: true,
                message: "something not right",
                onContinually: settings.onContinually,
                startTime: settings.startTime,
                endTime: settings.endTime,
                useCelsius: settings.useCelsius,
            });
        }
    },
} satisfies Actions;
