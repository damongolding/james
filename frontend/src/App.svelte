<script lang="ts">
    import { Toast } from "flowbite-svelte";
    import { onMount } from "svelte";
    import { fade } from "svelte/transition";

    import "./app.css";
    // @ts-ignore
    import { CheckCircleSolid } from "flowbite-svelte-icons"; // @ts-ignore
    import RangeSlider from "svelte-range-slider-pips"; // @ts-ignore

    interface Settings {
        useCelsius: boolean;
        onContinually: boolean;
        startTime: number;
        endTime: number;
        compensateTemperature: boolean;
        compensateTemperatureFactor: number;
        manualTemperatureOffset: number;
    }

    interface Response {
        success: boolean;
        saved: boolean;
    }

    let onContinually = false;
    let values = [7, 18];
    let useCelsius = true;
    let compensateTemperature = true;
    let compensateTemperatureFactor = 2.6;
    let manualTemperatureOffset = 0;

    const sliderVerticalMax = 1025;
    let windowWidth = 0;
    $: sliderVertical = windowWidth > sliderVerticalMax ? false : true;
    $: displaySuffix =
        windowWidth < 1280 ? (sliderVertical ? ":00" : "") : ":00";

    let showToast = false;
    let counterToast = 6;

    const debounce = (func: Function, delay: number) => {
        let timer: number;

        return function (this: Function) {
            const context = this;
            const args = arguments;
            clearTimeout(timer);
            timer = setTimeout(() => func.apply(context, args), delay);
        };
    };

    const getWindowWidth = () => (windowWidth = window.innerWidth);

    const debouncedGetWindowWidth = debounce(getWindowWidth, 300);

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

    onMount(async (): Promise<any> => {
        try {
            const request = await fetch("/settings");
            const settings: Settings = await request.json();

            useCelsius = settings.useCelsius;
            onContinually = settings.onContinually;
            values = [settings.startTime, settings.endTime];
            compensateTemperature = settings.compensateTemperature;
            compensateTemperatureFactor = settings.compensateTemperatureFactor;
            manualTemperatureOffset = settings.manualTemperatureOffset;
        } catch {
            console.error("Couldn't get settings");
        }

        getWindowWidth();
        window.addEventListener("resize", debouncedGetWindowWidth);

        return () => {
            window.removeEventListener("resize", debouncedGetWindowWidth);
        };
    });
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
            <hr />
            <div>
                <div class="flex flex-col items-start">
                    <label for=""><h3>Manual temperature offset</h3> </label>
                    <p class=" text-gray-700">
                        <small
                            >Use a negative number to lower sensor reading</small
                        >
                    </p>
                    <p class="pb-2 text-red-700">
                        <small
                            >⚠️ Enabling CPU compensation will negate/bypass
                            this</small
                        >
                    </p>
                    <input
                        type="number"
                        id="manual-temperature-offset"
                        name="manual-temperature-offset"
                        class="cursor-pointer w-32"
                        step="0.1"
                        bind:value={manualTemperatureOffset}
                    />
                    <p class="pb-2 mt-4 text-gray-700">
                        <small
                            >* Formula used: <code
                                class="bg-gray-700 text-white px-4 py-2 rounded-md ml-4"
                                >raw_temp + manualTemperatureOffset e.g. 22 + {manualTemperatureOffset}
                                = {22 + manualTemperatureOffset}c
                            </code></small
                        >
                    </p>
                </div>
            </div>
            <hr />
            <div>
                <div class="flex items-center">
                    <input
                        type="checkbox"
                        id="compensate-temperature"
                        name="compensate-temperature"
                        class="cursor-pointer"
                        value={compensateTemperature}
                        bind:checked={compensateTemperature}
                    />
                    <label
                        for="compensate-temperature"
                        class="pl-2 cursor-pointer"
                    >
                        <h2 class="text-xl">CPU temperature compensate</h2>
                    </label>
                </div>
                <p class="pt-1 text-gray-700">
                    <small>
                        {#if compensateTemperature}
                            Disabling this will use the raw output from the C02
                            sensor.
                        {:else}
                            Enabling this will offset the output from the C02
                            sensor using CPU temperature.
                        {/if}
                    </small>
                </p>
            </div>
            <div class={compensateTemperature ? "" : "disabled"}>
                <div class="flex flex-col items-start">
                    <label
                        for="compensate-temperature-factor"
                        class="cursor-pointer"
                    >
                        <h3 class="text-md">Compensate factor*</h3>
                    </label>
                    <p class="pb-2 text-gray-700">
                        <small>Lower = more compensation</small>
                    </p>
                    <input
                        type="number"
                        id="compensate-temperature-factor"
                        name="compensate-temperature-factor"
                        class="cursor-pointer w-32"
                        step="0.1"
                        bind:value={compensateTemperatureFactor}
                    />
                    <p class="pb-2 mt-4 text-gray-700">
                        <small
                            >* Formula used: <code
                                class="bg-gray-700 text-white px-4 py-2 rounded-md ml-4"
                                >raw_temp - ((cpu_temp - raw_temp) / {compensateTemperatureFactor}))</code
                            ></small
                        >
                    </p>
                </div>
            </div>
            <hr />
            <div class="">
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
                        <h2 class="text-xl">Keep the display on permanently</h2>
                    </label>
                </div>
                <p class="pt-1 text-gray-700">
                    <small>
                        {#if onContinually}
                            Disabling this will allow you to choose a time range
                        {:else}
                            Enable this to have the display on permanently
                        {/if}
                    </small>
                </p>
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
                    suffix={displaySuffix}
                    springValues={{ stiffness: 0.15, damping: 0.5 }}
                    disabled={onContinually}
                    vertical={sliderVertical}
                    reversed={sliderVertical}
                />
                <input type="hidden" name="start-time" value={values[0]} />
                <input type="hidden" name="end-time" value={values[1]} />
            </div>

            <div class={`${sliderVertical ? "pt-0" : "pt-24"} pb-2`}>
                <hr />
            </div>

            <div class="flex items-center">
                <button
                    class="rounded-md mr-8 py-2 px-12 bg-green-500 hover:bg-green-700 text-white font-bold text-xl"
                    >Save</button
                >
            </div>
        </div>
    </form>
</main>

<Toast
    color="none"
    position="bottom-right"
    transition={fade}
    params={{ x: 200 }}
    divClass="w-full max-w-xs p-4 text-white bg-green-600 shadow gap-3"
    bind:open={showToast}
>
    <svelte:fragment slot="icon">
        <CheckCircleSolid name="check-circle-solid" class="w-5 h-5" />
        <span class="sr-only">Check icon</span>
    </svelte:fragment>
    Settings saved.
</Toast>

<style>
    :root {
        --range-range: rgb(14, 159, 110);
        --range-handle-inactive: var(--range-range);
    }

    .disabled {
        opacity: 0.5;
    }
</style>
