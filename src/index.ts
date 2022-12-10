import { CustomWindow } from "./interfaces";
import { Window } from "./classes/Window";

export const addon = require("bindings")("addon.node"),
	askForScreenCaptureAccess = (): void => {
		if (!addon || !addon.askForScreenCaptureAccess) return;
		addon.askForScreenCaptureAccess();
	},
	checkScreenCaptureAccess = (): boolean => {
		if (!addon || !addon.checkScreenCaptureAccess) return false;
		return addon.checkScreenCaptureAccess();
	},
	getWindows = (): Window[] => {
		if (!addon || !addon.getWindows) return [];
		return addon
			.getWindows()
			.map(win => new Window(win.windowID))
			.filter(win => win.isWindow());
	},
	getActiveWindow = (): CustomWindow | {} => {
		if (!addon || !addon.getActiveWindow) return {};
		return addon.getActiveWindow();
	};

export { Window };
