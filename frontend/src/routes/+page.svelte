<script lang="ts">
    import { enhance } from "$app/forms";
    import type { ActionData, PageData } from "./$types";

    import RangeSlider from "svelte-range-slider-pips";

    let values = [7, 18];
    let onContinually = true;

    export let form: ActionData;
    export let data: PageData;
</script>

{data.settings.temperature}

<main class="container mx-auto p-8">
    <h1 class="text-4xl my-12">Air Monitor Settings</h1>

    {#if form?.error}
        <div class="my-24 p-8 bg-red-400 text-white rounded-md">
            <p>{form?.message}</p>
        </div>
    {/if}

    {#if form?.success}
        <div class="my-24 p-8 bg-green-400 text-white rounded-md">
            <p>Saved</p>
        </div>
    {/if}

    <form method="POST" use:enhance>
        <div class="space-y-8">
            <div>
                <label for="name">Name</label>
                <input
                    type="text"
                    name="name"
                    id="name"
                    value={form?.name ?? data.settings.name}
                />
            </div>
            <div>
                <label for="email">Email</label>
                <input
                    name="email"
                    type="email"
                    id="email"
                    value={form?.email ?? data.settings.email}
                />
            </div>
            <div>
                <h2 class="text-xl mb-2">Temperature</h2>
                <div class="pl-4 mb-2 cursor-pointer flex items-center">
                    <input
                        type="radio"
                        class="cursor-pointer"
                        name="temperature"
                        id="c"
                        value="C"
                        checked={form?.temperature == "F" ? false : true}
                    />
                    <label for="c" class="pl-2 cursor-pointer">Celsius</label>
                </div>
                <div class="pl-4 mb-2 cursor-pointer flex items-center">
                    <input
                        type="radio"
                        class="cursor-pointer"
                        name="temperature"
                        id="f"
                        value="F"
                        checked={form?.temperature == "F" ? true : false}
                    />
                    <label for="f" class="pl-2 cursor-pointer">Fahrenheit</label
                    >
                </div>
            </div>
            <div class="flex items-center">
                <input
                    type="checkbox"
                    id="on-continually"
                    name="on-continually"
                    class="cursor-pointer"
                    bind:checked={onContinually}
                />
                <label for="on-continually" class="pl-2 cursor-pointer">
                    <h2 class="text-xl">On all day</h2>
                </label>
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

            <div class="pt-24 pb-2">
                <hr />
            </div>

            <button
                class="rounded-md py-2 px-12 bg-green-600 text-white font-bold text-xl"
                >Save</button
            >
        </div>
    </form>
</main>

<style>
    :root {
        --range-handle-inactive: #9893dd;
    }

    .disabled {
        opacity: 0.5;
    }
</style>
