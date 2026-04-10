# Repository Notes

## Scope

This repository currently contains the maintained fork of `amap_flutter_map_plus` only.

It does not yet vendor `amap_flutter_base_plus`. The package still depends on:

```yaml
amap_flutter_base_plus: ^3.1.0
```

## Why split it out

- Keep plugin maintenance independent from the main app repository.
- Track native/plugin fixes with dedicated commits and tags.
- Make it possible to switch the app from a local `third_party/` copy to a git dependency later.

## Next recommended steps

1. Initialize a separate git history for this directory.
2. Commit the current extracted state as the baseline import.
3. Cherry-pick or recreate your local bug fixes as focused commits.
4. Add CI for at least `flutter analyze` and an Android example build.
5. Decide whether `amap_flutter_base_plus` also needs to be forked.
