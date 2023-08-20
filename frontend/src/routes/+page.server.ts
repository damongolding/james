import type { Actions } from "./$types";
export const actions = {
    default: async ({ request }) => {
        const data = await request.formData();
        const name = data.get("name");
        const email = data.get("email");
        const startTime = data.get("start-time");
        const endTime = data.get("end-time");

        for (const thing of data) {
            console.log(thing);
        }

        // return fail(404, { error: true, message: "ass", success: false });
        return { success: true, name, email, startTime, endTime };
    },
} satisfies Actions;
