import { addon } from "..";

export class Window {
	windowID: number;
	pid: number;
	bundlePath: string;

	constructor(windowID: number) {
		this.windowID = windowID;

		const { pid, bundlePath } = addon.getWindowInfo(this.windowID);

		this.pid = pid;
		this.bundlePath = bundlePath;
	}

	getTitle(): string {
		return addon.getWindowTitle(this.windowID);
	}

	isActive(): boolean {
		return addon.isWindowActive(this.windowID);
	}

	isWindow(): boolean {
		return this.bundlePath && !!addon.getWindowInfo(this.windowID);
	}

	getIcon(size: number): Buffer {
		return addon.getAppIcon(this.bundlePath, size);
	}

	toJSON() {
		return {
			windowID: this.windowID,
			pid: this.pid,
			bundlePath: this.bundlePath
		};
	}
}
