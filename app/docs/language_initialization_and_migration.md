# Language initialization and migration

TalkLog resolves language settings in this order:

1. Use a valid locally saved app language (`ja`, `en`, or `es`).
2. If it is missing or invalid, use the device language when it is supported.
3. Otherwise, use English as the app language.
4. Use a valid locally saved learning language when present.
5. If it is missing or invalid, use Spanish as the learning language.
6. If both languages would be the same, choose the first supported learning
   language other than the app language. With the current ordering this is
   Japanese for Spanish users.

Legacy Japanese labels such as `日本語` and `中国語` are accepted when reading
old local data. After loading, both values are persisted as stable language
codes, so the migration happens automatically without changing a valid user
selection.

Cloud settings are applied only when both language values are recognized and
the app and learning languages differ. Invalid or incomplete cloud rows do not
overwrite a valid local selection.
