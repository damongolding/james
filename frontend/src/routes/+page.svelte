<script lang="ts">
    import { enhance } from "$app/forms";
    import type { ActionData } from "./$types";

    import RangeSlider from "svelte-range-slider-pips";

    let values = [7, 18];
    let onContinually = true;

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
        <label for="c">Celsius</label>
        <input
            type="radio"
            name="temp"
            id="c"
            value="C"
            checked={form?.temp == "F" ? false : true}
        />
        <label for="f">Fahrenheit</label>
        <input
            type="radio"
            name="temp"
            id="f"
            value="F"
            checked={form?.temp == "F" ? true : false}
        />
    </div>
    <div>
        <label for="on-continually">On all day</label>
        <input
            type="checkbox"
            id="on-continually"
            name="on-continually"
            bind:checked={onContinually}
        />
    </div>
    <div class={onContinually ? "disabled" : ""}>
        <RangeSlider
            bind:values
            min={0}
            max={24}
            range
            float
            pips
            hoverable
            all="label"
            suffix=":00"
            disabled={onContinually}
        />
        <input type="hidden" name="start-time" value={values[0]} />
        <input type="hidden" name="end-time" value={values[1]} />
    </div>

    <button>Send</button>
</form>

{#if form?.error}
    <p>{form?.message}</p>
{/if}

{#if form?.success}
    <!-- this message is ephemeral; it exists because the page was rendered in
       response to a form submission. it will vanish if the user reloads -->
    <p>Successfully logged in! Welcome back</p>
{/if}

<style>
    :root {
        --range-handle-inactive: #9893dd;
    }
    .disabled {
        opacity: 0.5;
    }
</style>
