interface ElmApp {
    ports: {
        saveStorage: { subscribe: (callback: (data: unknown) => void) => void };
        triggerPrint: { subscribe: (callback: () => void) => void };
        downloadFile: { subscribe: (callback: (data: { name: string; content: string }) => void) => void };
        selectFile: { subscribe: (callback: () => void) => void };
        fileContentReceived: { send: (content: string) => void };
    };
}

declare const Elm: { Main: { init: (config: { node: HTMLElement | null; flags: unknown }) => ElmApp } };

const storedData = localStorage.getItem('facturasData');
const initialFlags: unknown = storedData ? JSON.parse(storedData) : null;
console.log("Flags enviados a Elm:", initialFlags);

const app = Elm.Main.init({
    node: document.getElementById('elm-app'),
    flags: initialFlags
});

app.ports.saveStorage.subscribe((data: unknown) => {
    localStorage.setItem('facturasData', JSON.stringify(data));
});

app.ports.triggerPrint.subscribe(() => {
    window.print();
});

app.ports.downloadFile.subscribe((data: { name: string; content: string }) => {
    const blob = new Blob([data.content], { type: 'text/csv' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = data.name;
    a.click();
    URL.revokeObjectURL(url);
});

const fileInput = document.createElement('input');
fileInput.type = 'file';
fileInput.accept = '.csv';

app.ports.selectFile.subscribe(() => {
    fileInput.click();
});

fileInput.onchange = (e: Event) => {
    const target = e.target as HTMLInputElement;
    const file = target.files?.[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = (event: ProgressEvent<FileReader>) => {
        const content = event.target?.result as string;
        app.ports.fileContentReceived.send(content);
    };
    reader.readAsText(file);
};
