# Release process / 发布流程

The TextMate and legacy Vim-syntax tracks use immutable, annotated Git tags:

- `tm-v<version>` for `grammars/bird2.tmLanguage.json`
- `vim-v<version>` for the Vim syntax snapshot selected by the tag's
  `external/bird2.vim` submodule pointer

TextMate 与兼容用途的 Vim syntax 轨道均以 annotated tag 作为唯一资产来源。
Release 附件不得从 tag 之后的 `main` 工作树生成，也不得移动已发布 tag。

## Prepare a release / 准备发布

1. Consume the relevant change fragments into `CHANGELOG.md` and update the
   grammar or syntax versions.
2. Run `prek run --all-files` and inspect `node scripts/release.js` output.
3. Merge the reviewed release commit to `main`.
4. Create the applicable annotated tag or tags on that exact commit. Push at
   most three tags in one command so GitHub emits every push event.
5. The Release workflow checks out current tooling but exports bytes from the
   selected tag. TextMate assets come from the tag blob; symlinked Vim assets
   come from the exact submodule gitlink stored by that tag.

## Verify an asset / 验证资产

```sh
node scripts/export-release-asset.mjs export tm-v1.0.13-20260717 dist
node scripts/export-release-asset.mjs export vim-v1.0.13-20260717 dist
```

The command rejects a tag whose declared track or version does not match the
exported file. CI additionally parses the TextMate JSON or sources the Vim file
headlessly and preserves the exported file as a workflow artifact. Historical
Vim beta tags are preserved byte-for-byte and receive version validation only;
stable Vim tags must load successfully in headless Vim.

## Restore a historical attachment / 修复历史附件

Run the Release workflow manually with an existing tag. Existing Release title,
notes, draft state, prerelease state, and latest state are preserved; only the
single track asset is rebuilt from the immutable tag and uploaded with
`--clobber`. The workflow refuses to create an unknown historical release from
the current working tree.
