// Все тексты страницы. Русский дублируется в index.html — его видно, пока скрипт не загрузился.
export const STRINGS = {
  ru: {
    meta: {
      title: "TTL Fix",
      description: "TTL Fix — меняет TTL одной кнопкой, чтобы раздавать интернет с Mac и Windows.",
    },
    header: { home: "На главную", interfaceLanguage: "Язык интерфейса" },
    uiLanguages: { ru: "RU", en: "EN" },
    hero: {
      subtitle: "Раздавайте интернет с Mac или Windows: TTL меняется одной кнопкой, а приложение показывает, получилось ли.",
    },
    downloads: { mac: "Скачать для macOS", windows: "Скачать для Windows" },
    screenshot: { alt: "Окно TTL Fix на macOS: зелёная кнопка «TTL 65 — switch to 64»" },
    howTo: {
      title: "Как пользоваться",
      use: "Нажмите большую кнопку TTL и подтвердите запрос администратора. Зелёный цвет — настройка применена, красный — отменено или произошла ошибка.",
      unsigned: "Приложение пока не подписано, поэтому при первом запуске macOS и Windows могут попросить подтверждение.",
    },
    footer: { warning: "Приложение меняет системные сетевые настройки — используйте его только там, где вам это разрешено." },
  },
  en: {
    meta: {
      title: "TTL Fix",
      description: "TTL Fix changes TTL with one button so you can share the internet from a Mac or Windows PC.",
    },
    header: { home: "Home", interfaceLanguage: "Interface language" },
    uiLanguages: { ru: "RU", en: "EN" },
    hero: {
      subtitle: "Share the internet from a Mac or Windows PC: change TTL with one button and see right away whether it worked.",
    },
    downloads: { mac: "Download for macOS", windows: "Download for Windows" },
    screenshot: { alt: "TTL Fix window on macOS with a green “TTL 65 — switch to 64” button" },
    howTo: {
      title: "How to use",
      use: "Press the large TTL button and approve the administrator request. Green means the setting was applied; red means it was cancelled or an error occurred.",
      unsigned: "The app is not signed yet, so macOS and Windows may ask you to confirm the first launch.",
    },
    footer: { warning: "The app changes system network settings — use it only on devices and networks you are allowed to configure." },
  },
};
