# Publish `speckit-auto-spec` to npm

Unscoped package — same style as `npx rooty-investigator install`.

> **Note:** The name `auto-spec` is already used on npm by another project. This CLI is published as **`speckit-auto-spec`**.

## One-time setup

1. Account at [npmjs.com](https://www.npmjs.com/signup)
2. Token with **publish** permission: [npmjs.com/settings/~/tokens](https://www.npmjs.com/settings/~/tokens)

## Login

```bash
cd path/to/auto-spec
npm login
npm whoami
```

## Publish

```bash
npm pack --dry-run
npm publish
```

## After publish

```bash
npx speckit-auto-spec install
```

## New versions

Bump `"version"` in `package.json`, then `npm publish`.

If publish fails with **401**, run `npm login` again. **403** usually means the package name is owned by another npm user.
