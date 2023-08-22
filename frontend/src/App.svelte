<script lang="ts">
    import { Toast } from "flowbite-svelte";
    import { onMount } from "svelte";
    import { fly } from "svelte/transition";

    import "./app.css";
    // @ts-ignore
    import { Icon } from "flowbite-svelte-icons"; // @ts-ignore
    import RangeSlider from "svelte-range-slider-pips"; // @ts-ignore

    interface Settings {
        useCelsius: boolean;
        onContinually: boolean;
        startTime: number;
        endTime: number;
    }

    interface Response {
        success: boolean;
        saved: boolean;
    }

    let onContinually = false;
    let values = [7, 18];
    let useCelsius = true;

    let showToast = false;
    let counterToast = 6;

    onMount(async () => {
        const request = await fetch("/settings");
        const settings: Settings = await request.json();

        useCelsius = settings.useCelsius;
        onContinually = settings.onContinually;
        values = [settings.startTime, settings.endTime];
    });

    const formHandler = async (e: SubmitEvent) => {
        const formData = new FormData(e.target as HTMLFormElement);
        const data = new URLSearchParams();
        for (let field of formData) {
            const [key, value] = field;
            data.append(key, <string>value);
        }

        const response = await fetch("/", {
            method: "POST",
            body: data,
        });
        const r: Response = await response.json();

        if (r.saved && r.success) {
            showToast = true;
            counterToast = 6;
            timeout();
        }
    };

    function timeout() {
        if (--counterToast > 0) return setTimeout(timeout, 1000);
        showToast = false;
    }
</script>

<main class="container mx-auto p-8">
    <h1 class="text-4xl my-12">Air Monitor Settings</h1>

    <form method="POST" on:submit|preventDefault={formHandler}>
        <div class="space-y-8">
            <div>
                <h2 class="text-xl mb-2">Temperature</h2>
                <div class="pl-4 mb-2 cursor-pointer flex items-center">
                    <input
                        type="radio"
                        class="cursor-pointer"
                        name="use-celsius"
                        id="c"
                        value={true}
                        bind:group={useCelsius}
                    />
                    <label for="c" class="pl-2 cursor-pointer">Celsius</label>
                </div>
                <div class="pl-4 mb-2 cursor-pointer flex items-center">
                    <input
                        type="radio"
                        class="cursor-pointer"
                        name="use-celsius"
                        id="f"
                        value={false}
                        bind:group={useCelsius}
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
                    value="true"
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

            <div class="flex items-center">
                <button
                    class="rounded-md mr-8 py-2 px-12 bg-green-600 hover:bg-green-700 text-white font-bold text-xl"
                    >Save</button
                >
            </div>
        </div>
    </form>
</main>

<Toast
    color="none"
    position="bottom-right"
    transition={fly}
    params={{ x: 200 }}
    divClass="w-full max-w-xs p-4 text-white bg-green-600 shadow gap-3"
    bind:open={showToast}
>
    <svelte:fragment slot="icon">
        <Icon name="check-circle-solid" class="w-5 h-5" />
        <span class="sr-only">Check icon</span>
    </svelte:fragment>
    Settings saved.
</Toast>

<style>
    :root {
        --range-handle-inactive: #9893dd;
    }

    .disabled {
        opacity: 0.5;
    }
</style>
