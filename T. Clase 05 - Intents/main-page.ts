import {
  Application,
  EventData,
  Page,
  Image,
  TextField,
  TextView,
  Label,
  ImageSource
} from "@nativescript/core";

// Variable global para acceder a la página desde cualquier función
let page: Page;

// ──────────────────────────────────────────────
// CICLO DE VIDA
// ──────────────────────────────────────────────

export function onPageLoaded(args: EventData) {
  page = args.object as Page;

  // Registrar el listener de resultado de cámara UNA SOLA VEZ al cargar la página
  Application.android.on("activityResult", onActivityResult);
}

export function onNavigatedTo(_args: any) {
  // Cada vez que la pantalla aparece (incluso al volver de la cámara o de otra app)
  processIncomingIntent();
}

// ──────────────────────────────────────────────
// SECCIÓN A — SALIENTES
// ──────────────────────────────────────────────

export function onDial() {
  const phoneField = page.getViewById<TextField>("phoneField");
  const number = phoneField?.text?.trim();

  if (!number) {
    alert("Por favor ingresa un número telefónico.");
    return;
  }

  const intent = new android.content.Intent(android.content.Intent.ACTION_DIAL);
  intent.setData(android.net.Uri.parse("tel:" + number));

  Application.android.foregroundActivity.startActivity(intent);
}

const CAMERA_REQUEST_CODE = 1001;

export function onTakePhoto() {
  const intent = new android.content.Intent(android.provider.MediaStore.ACTION_IMAGE_CAPTURE);
  Application.android.foregroundActivity.startActivityForResult(intent, CAMERA_REQUEST_CODE);
}

function onActivityResult(args: any) {
  if (args.requestCode !== CAMERA_REQUEST_CODE) return;
  if (args.resultCode !== android.app.Activity.RESULT_OK) return;
  if (!args.intent) return;

  const extras = args.intent.getExtras();
  if (!extras) return;

  const bitmap: android.graphics.Bitmap = extras.get("data");
  if (!bitmap) return;

  const imgSrc = new ImageSource();
  imgSrc.setNativeSource(bitmap);

  const preview = page.getViewById<Image>("photoPreview");
  if (preview) {
    preview.imageSource = imgSrc;
  }
}

// ──────────────────────────────────────────────
// SECCIÓN B — ENTRANTES
// ──────────────────────────────────────────────

export function processIncomingIntent() {
  if (!page) return;

  const activity = Application.android.foregroundActivity;
  if (!activity) return;

  const intent = activity.getIntent();
  if (!intent) return;

  const action = intent.getAction();
  const type   = intent.getType();

  console.log("=== INTENT RECIBIDO ===");
  console.log("action:", action);
  console.log("type:", type);

  if (action !== "android.intent.action.SEND") return;

  const statusLabel   = page.getViewById<Label>("statusLabel");
  const receivedText  = page.getViewById<TextView>("receivedText");
  const receivedImage = page.getViewById<Image>("receivedImage");

  if (type === "text/plain") {
    const text = intent.getStringExtra(android.content.Intent.EXTRA_TEXT) ?? "";

    if (statusLabel)   statusLabel.text = "Estado: Texto recibido ✅";
    if (receivedText)  receivedText.text = text;
    if (receivedImage) receivedImage.imageSource = undefined;

    // Consumir el intent para no reprocesarlo si el usuario navega dentro de la app
    activity.setIntent(new android.content.Intent());

  } else if (type && type.startsWith("image/")) {
    const uri = intent.getParcelableExtra(android.content.Intent.EXTRA_STREAM) as android.net.Uri;

    console.log("uri recibida:", uri);

    if (!uri) {
      console.log("URI es null/undefined - no se puede cargar la imagen");
      return;
    }

    try {
      // content:// se lee con ContentResolver, no con ImageSource.fromUrl()
      const contentResolver = Application.android.context.getContentResolver();
      const inputStream = contentResolver.openInputStream(uri);
      const bitmap = android.graphics.BitmapFactory.decodeStream(inputStream);
      inputStream.close();

      const imgSrc = new ImageSource();
      imgSrc.setNativeSource(bitmap);

      console.log("Imagen cargada correctamente desde content://");

      if (statusLabel)   statusLabel.text = "Estado: Imagen recibida ✅";
      if (receivedText)  receivedText.text = "[dato binario — imagen recibida]";
      if (receivedImage) receivedImage.imageSource = imgSrc;

    } catch (error) {
      console.log("ERROR al cargar imagen:", error);
      if (statusLabel) statusLabel.text = "Error al cargar la imagen.";
    }

    activity.setIntent(new android.content.Intent());
  }
}