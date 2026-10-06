// Язык страницы: переключатель RU / EN в шапке, выбор запоминается в браузере.
import { STRINGS } from "./strings.js";

const STORAGE_KEY = "ttlfix-ui-language";
const FALLBACK = "ru";
const UI_LANGUAGES = Object.keys(STRINGS);

let current = detectLanguage();

function detectLanguage() {
  try {
    const saved = localStorage.getItem(STORAGE_KEY);
    if (UI_LANGUAGES.includes(saved)) return saved;
  } catch {}
  const browser = (navigator.language || "").slice(0, 2).toLowerCase();
  return UI_LANGUAGES.includes(browser) ? browser : (browser ? "en" : FALLBACK);
}

const lookup = (table, key) => key.split(".").reduce((node, part) => node?.[part], table);
const t = (key) => lookup(STRINGS[current], key) ?? lookup(STRINGS[FALLBACK], key) ?? key;

function setLanguage(language) {
  if (!UI_LANGUAGES.includes(language) || language === current) return;
  current = language;
  try { localStorage.setItem(STORAGE_KEY, language); } catch {}
  applyToDocument();
}

// data-i18n="key" → textContent; data-i18n-<attr>="key" → атрибут.
function applyToDocument() {
  document.documentElement.lang = current;
  document.title = t("meta.title");
  document.querySelector('meta[name="description"]')?.setAttribute("content", t("meta.description"));
  document.querySelectorAll("*").forEach((element) => {
    for (const { name, value } of [...element.attributes]) {
      if (name === "data-i18n") element.textContent = t(value);
      else if (name.startsWith("data-i18n-")) element.setAttribute(name.slice("data-i18n-".length), t(value));
    }
  });
  for (const button of document.querySelector("[data-ui-languages]").children) {
    button.setAttribute("aria-pressed", String(button.dataset.lang === current));
  }
}

document.querySelector("[data-ui-languages]").append(...UI_LANGUAGES.map((lang) => {
  const button = document.createElement("button");
  button.type = "button";
  button.dataset.lang = lang;
  button.textContent = STRINGS[lang].uiLanguages[lang];
  button.addEventListener("click", () => setLanguage(lang));
  return button;
}));
applyToDocument();
