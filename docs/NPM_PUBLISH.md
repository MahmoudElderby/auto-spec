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

If publish fails with **403**: the scope does not match your npm user, or the name is taken by another account.
