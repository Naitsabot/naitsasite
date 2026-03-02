- [-] Switch from string-built HTML to a real template engine (Nimja, Mustache, etc.)
- [ ] Add dev-mode auto-reload for markdown content (watch file mtimes or use a watcher)
- [ ] Add tag pages: `/tags` and `/tags/:tag`
- [ ] Add RSS feed for `/blog`
- [ ] Add sitemap.xml and robots.txt
- [ ] Add OpenGraph/meta tags per document (title, summary, image)
- [ ] Improve markdown rendering (code highlighting, GFM tables) if needed
- [ ] Add navigation / header configuration (links in config)
- [ ] Add drafts handling rules (optional auth gating, or hide drafts always)
- [ ] Add search (simple in-memory index first)
- [ ] Make page faster for static content
    - [ ] backend:
        - [x] optimise images
            - [x] Proc for generating thumbs of static images, using nimagemagick
            - [x] Apply a filter/dithering to reduce size, and add fun effect
            - [x] Save thumbnails in a seperate folder (public/img/thumbs/)
        - [ ] **gzip** or Brotli compression for CSS, HTML, SVG ...
        - [ ] set cache-control ehaders for static assets so browser caches them (if that is not already done)
        - [ ] use lazy loading of images that arn't immediately visible
        - [ ] keep embedded SVGs small. If they are large, link htem to external files
    - [ ] frontend
        - [x] image size
            - [x] display thumbnails (on img with class="thumbable")
            - [x] Add functionallity, that when thumb is clicked, the image is shown in large size in an overlay



What's implemented so far:

✅ User registration + bcrypt password hashing
✅ Login → HttpOnly JWT cookie → redirect to /vault
✅ /vault protected, redirects to /vault-login if not authed
✅ Vault entries stored encrypted in DB, decrypted client-side with AES-GCM (server never sees the key)
✅ PBKDF2 key derived from password in browser on login, stored in sessionStorage
✅ Add / delete vault entries via JS fetch
✅ /reviews page — public read, post requires login
✅ /api/logout clears cookie
What still needs doing:

End-to-end browser test — run nimble run, register a user, log in, confirm the cookie appears in DevTools, add a vault entry and check it round-trips correctly (encrypt → store → fetch → decrypt)

Handle missing sessionStorage key gracefully — if a user navigates directly to /vault with a valid cookie but no key in sessionStorage (e.g. opened a new tab), they see a warning but can't decrypt. You may want to redirect them back to login in that case, or prompt for their password again to re-derive the key

Public visibility of reviews — currently /reviews is readable without login, which is correct, but verify this matches your requirements

Delete the stale psw.db if it still exists from before the bcrypt fix, otherwise old test users will fail to log in:
`rm psw.db && nimble run`


