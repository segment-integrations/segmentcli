# Edge Function Bundle

## Getting Started
- `yarn install`
- `yarn build`
  - `yarn build --watch` - use this command if you're actively editing your edge function bundle

## Useful commands
- `segmentcli edgefn test dist/bundle.ts`
- `segmentcli edgefn test dist/bundle.ts --input test/valid.json`

## Workflow
1. Edit the files in `src/index.ts`
1. Bundle your edge function into the final product using `yarn build`
1. Use the SegmentCLI to validate any changes `segmentcli edgefn test dist/bundle.js`. The CLI can check that:
    - the list of middleware was exported correctly
    - an event that flows through the middleware gets modified in the way that you're expecting.
1. Upload the bundle to S3 so it can be distributed to edge devices: `segmentcli edgefn upload dist/bundle.js`
