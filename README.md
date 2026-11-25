# Minky's Bookshelf

A cozy book blog with a shared bookshelf, owner-only editing, public reader suggestions and reviews, and a private inbox. The owner editor includes a large writing space, automatic private drafts, a reusable sticker shelf (stickers appear inline like emojis), and turns `--` into an em dash while writing. The public reading view is wider and easier to read.

## One-time secure setup

This site uses GitHub Pages for the public website and Supabase for sign-in and shared storage. GitHub Pages by itself cannot securely protect an edit button or share visitor messages between browsers. The owner account and database policies below do that.

If you are under 18, ask a parent or guardian to help with creating and managing the Supabase project/account. Never send your password or a Supabase secret key in a message.

1. Create a Supabase project at [supabase.com](https://supabase.com/). Keep the project private to your account.
2. In **Authentication → Users**, add one owner account using your email and a strong password. Turn off public sign-ups in **Authentication → Settings** so visitors cannot create accounts.
3. Open **SQL Editor**, paste and run all of `supabase-setup.sql`.
4. Copy the new owner's **User ID** from Authentication → Users. In SQL Editor run this, replacing the sample ID with that exact ID:

   ```sql
   insert into public.bookshelf_owners (user_id)
   values ('PASTE-THE-OWNER-USER-ID-HERE');
   ```

5. In **Project Settings → API**, copy the Project URL and the **publishable** key (sometimes labelled `anon` on older projects). Put them in `supabase-config.js`, replacing the two `YOUR_...` values. The publishable/anon key is made for use in a public webpage; never use a `secret` or `service_role` key here.
6. Upload the updated `index.html`, `supabase-setup.sql`, `README.md`, and the image files `minky-happy.png`, `minky-reading.jpg`, `orange-sticker.png` to the GitHub repository, replacing its earlier copies. GitHub Pages will rebuild the website.
7. Open the site link, choose **Owner sign in**, and log in. Visitors can suggest books and leave notes; only the signed-in owner account listed in `bookshelf_owners` can edit books or open the inbox.

The database policies are the security boundary: hiding the edit controls alone would not protect the data. Book covers and stickers are stored as image data in the database, so use reasonably sized images. Suggestions and comments are saved to the shared inbox; they are not shown publicly on the book page. Drafts and the reusable sticker collection are private to the owner account.

