<script lang="ts">
    import { enhance } from "$app/forms";
    import type { ActionData } from "./$types";

    import RangeSlider from "svelte-range-slider-pips";

    export let form: ActionData;
</script>

<form method="POST" use:enhance>
    <div>
        <label for="name">Name</label>
        <input type="text" name="name" id="name" value={form?.name ?? ""} />
    </div>
    <div>
        <label for="email">Email</label>
        <input name="email" type="email" id="email" value={form?.email ?? ""} />
    </div>
    <div>
        <label for="time">Start Time</label>
        <input type="time" name="start-time" value={form?.startTime ?? ""} />
    </div>
    <div>
        <label for="time">End Time</label>
        <input type="time" name="end-time" value={form?.endTime ?? ""} />
    </div>

    <div>
        <RangeSlider
            min={0}
            max={24}
            values={[7, 18]}
            range
            float
            pips
            all="label"
            suffix=":00"
        />
    </div>

    <button>Send</button>
</form>

{#if form?.error}
    <p>{form.message}</p>
{/if}

{#if form?.success}
    <!-- this message is ephemeral; it exists because the page was rendered in
       response to a form submission. it will vanish if the user reloads -->
    <p>Successfully logged in! Welcome back</p>
{/if}
