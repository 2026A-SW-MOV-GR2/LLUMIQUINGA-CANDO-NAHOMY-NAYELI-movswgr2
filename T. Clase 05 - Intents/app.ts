import { Application } from "@nativescript/core";
import { processIncomingIntent } from "./main-page";

Application.android.on("activityNewIntent", (args: any) => {
  if (args && args.intent) {
    args.activity.setIntent(args.intent);
    processIncomingIntent();
  }
});

Application.run({ moduleName: "app-root" });