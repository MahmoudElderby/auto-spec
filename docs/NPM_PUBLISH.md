# Publish `@mahmoudelderby/auto-spec` to npm

The scoped package name **must match your npm username** (usually all lowercase: `mahmoudelderby`).

## One-time setup

1. Create an account at [npmjs.com](https://www.npmjs.com/signup) if needed.
2. Create a granular or classic token: [npmjs.com/settings/~/tokens](https://www.npmjs.com/settings/~/tokens)  
   - Classic: **Publish** permission  
   - Granular: scope `@mahmoudelderby`, packages read/write

## Login (interactive)

```bash
cd path/to/auto-spec
npm login
npm whoami
```

You should see your npm username (e.g. `mahmoudelderby`).

## Publish

```bash
cd path/to/auto-spec
npm pack --dry-run
npm publish
```

`publishConfig.access` is already `public` in `package.json`.

## After publish

Users install with:

```bash
npx @mahmoudelderby/auto-spec install
```

## New versions

1. Bump `"version"` in `package.json` (semver).
2. Commit and tag on GitHub if you want (`git tag v1.2.2` optional — extension zip tag can differ).
3. `npm publish` again.

If publish fails with **403** or **404** on PUT:

- Run `npm login` again (expired token shows as 401 on `npm whoami` or 404 on publish).
- The scope **`@mahmoudelderby`** must match your npm username exactly (check at npmjs.com/settings/profile). If your username differs, change `"name"` in `package.json` to `@<your-npm-username>/auto-spec`.
- Use a token with **publish** access; enable 2FA on the account if npm requires it for publish.

Verify before publish:

```bash
npm whoami
npm pack --dry-run
npm publish
```
