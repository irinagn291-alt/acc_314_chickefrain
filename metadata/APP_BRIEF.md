<!-- gf-brief source=f4166e22e98648795b5ddd3646412075eff7e0305c69a8a3f899c93d1e978145 written=2026-10-22T02:22:43+03:00 -->
# Chickefrain
## What it is
Chickefrain is a private reading notebook for someone who wants to keep a line after the book is finished. You save books, write lines from them, and attach one word to a line. When the same word sits on three different books, Weave seats three of those lines for the day.

## Launch and onboarding
A cold launch shows the system launch screen, then the home screen titled "Quotes" as a placeholder while the library loads. On a first launch the intro replaces that home screen. It has three pages, with page dots and no other controls besides the buttons below.

Page 1 title: "Keep the line". Body: "Save a line from a book you finished. It stays after the book is gone." Buttons: "Next" and "Skip".

Page 2 title: "Weave today". Body: "When one word sits on three books, Weave seats three lines for this day." Buttons: "Next" and "Skip".

Page 3 title: "Reopen the day". Body: "Reopen if you want a different three. The word stays on each line." Button: "Continue". "Skip" is not shown.

"Next" advances one page. "Skip" or "Continue" leaves the intro and opens "Quotes". The intro does not appear again unless "Show intro again" is used in "Settings". The whole app is dark. There is no account prompt.

## Screens
### Quotes
Title: "Quotes". This is the only home screen. There is no tab bar. Other screens open as sheets from the buttons here.

At the top, a status sentence, then today's date in the form "October 21, 2026", then a large word. With nothing chosen the large word reads "Your word". After words exist it shows the selected word.

Status sentences:
- "Add a book, save a line, then tap Weave." when the library is empty.
- "One word needs to sit on three books." when lines exist but no word is shared by three books.
- "Save a word on a line, then tap Weave." after Weave is tapped and no line has a word.
- "No word is on three books yet." after Weave is tapped and a word exists on fewer than three books.
- "Ready. Tap Weave to seat these three lines." when one word is on three books and today is not seated.
- "Seated for today. Tap Reopen to choose again." after today has been seated.

Under the large word, the label is "No shared word yet." plus "Save a word on a line to light Weave." until a word is saved. After that the label is "Words on your lines" and each saved word is a button. Tapping a word selects it. A word that is on three books is marked ready.

A heading sits above the line cards:
- "No lines for this word yet"
- "Lines saved for this word"
- "Three lines from three books" when three lines are ready
- "Seated from three books" after Weave

Each card shows the book title and the line. Tapping a card opens "Word" for that line. If the book title is missing, the card says "Book".

"Weave" seats three lines for today from the selected word when that word is on three books. It is disabled after today is seated. If the word is not ready, the status sentence changes and nothing is seated.

Six buttons:
- "Reopen" is disabled until today is seated. It clears today's three seated lines. The words stay on the lines, and "Weave" can be used again.
- "Add line" opens "Add a line".
- "Shelf" opens "Shelf".
- "Days" opens "Days".
- "Counts" opens "Counts".
- "Settings" opens "Settings".

A count card shows the number of "Lines saved", a label like "2 books", and "0 words ready", "1 word ready", or "2 words ready".

If the library cannot be read, a banner says "Library failed to load." followed by "Saved library could not be read. Started from an empty shelf." and a "Retry" button.

### Add a line
Title: "Add a line". Close is the X at the top left.

If there is no book: "Add a book before a line." and "A line belongs to one book." There is no save button. Add a book from "Shelf" first.

Otherwise the form has "Book" (a menu of book titles), "Line", "Page" with placeholder "Optional", and "Word". The note under Word says: "A word is saved on this line. Three books with the same word make Weave live." "Save line" is disabled until a book is chosen and the line is not blank. A filled page must be a whole number; digits only are kept. Word may be left blank. The keyboard has "Done".

If the line, page, or word has been typed, the X asks "Leave without saving?" with "Discard" and "Keep editing". "Save line" stores the line on the chosen book, stores the word when one was typed, and returns to "Quotes".

### Word
Title: "Word". Opened from a line card on "Quotes". Close is the X.

It shows "Save a word", then "Three books that share it make Weave live for today.", then the line, a field labeled "Word", and "Save word". "Save word" stays disabled while the field is blank. Saving stores the word in lowercase with extra spaces removed, then returns to "Quotes". If there is no line, the screen says "Add a line first." and has no save button. The keyboard has "Done".

### Shelf
Title: "Shelf". Close is the X.

Empty: "The shelf is empty." and "Set down your first book and leave a line in the margin." Button: "Add a book".

With books, the first book is a large card: title, a percent such as "20%" or "unknown", author, a chip "On shelf, Once", "On shelf, Reread", "Gone, Once", or "Gone, Reread", and a progress bar. Later books are rows with the title, that same chip, the percent, and a chevron. Tapping a book opens "Book". "Add a book" stays at the bottom.

If the shelf cannot be read and there are no books: "Shelf failed to load.", the same recovery sentence, and "Retry".

### Add a book
Title: "Add a book". Fields: "Title", "Author", and "Pages" with placeholder "0". The keyboard has "Done". Non-digits in Pages are dropped. If Pages is not a whole number, the screen says "Pages must be a whole number." "Save book" stays disabled until title and author are filled and Pages is valid. An empty Pages field is saved as 0. Saving returns to "Shelf". A new book starts at page 0, "On shelf", and "Once".

After any field is edited, the back control is "Back". It asks "Leave without saving?" with "Discard" and "Keep editing".

### Book
Title: "Book". It shows the percent or "unknown", the title, and the author.

"Reread" and "Once" switch the book's mark. The selected one is checked.

Page controls are minus and plus, named "Previous page" and "Next page". Between them is the current page and "of" the total, for example "0" and "of 240". The page does not go below 0. If the total is greater than 0, it does not go past the total. A total of 0 keeps the percent as "unknown".

While the book is on the shelf, "Mark gone" asks "Mark this book gone?" with the message "This book leaves the held shelf. Lines stay and can still be woven." Buttons: "Mark gone" and "Cancel". After that, the button is replaced by "Gone. Lines remain." The book stays listed on "Shelf" as "Gone".

A "Lines" heading lists each line, its word or "No word", and its page number when one was saved. If there are none: "No lines in this book yet."

If the book is missing: "That book is not on the shelf." and "It may have been removed."

### Days
Title: "Days". Close is the X.

Empty library: "No days yet." and "Weave a day and the three lines land here."

Otherwise the screen shows today's date and "A ready day has the same word on three books. A seated day keeps those three lines. Tap a day to read them." Each day shows its date, "Show lines" or "Hide lines", and a chip: "Empty", "Waiting", "Ready", or "Seated".

Expanded copy:
- "Empty": "This day has no books yet."
- "Waiting": "Waiting for one word on three books."
- "Ready": "Ready to seat. These lines share one word." plus "Weave this day".
- "Seated": "Seated. These are the three lines kept for the day." plus "Reopen this day".

Lines show the book title, or "Book", and the line. If none: "No lines saved for this day yet." "Weave this day" seats that day. "Reopen this day" clears that day's seated lines and leaves the words on the lines.

If days cannot be read: "Days failed to load.", the recovery sentence, and "Retry".

### Counts
Title: "Counts". Close is the X.

Empty: "No words counted yet." and "Save a word on a line. Counts show up here."

With words: "Tap a word to read its lines" and a streak such as "0 days seated in a row" or "3 days seated in a row". The streak counts seated days in a row, ending today if today is seated, otherwise ending yesterday. Up to six words appear, most lines first. Each row is the word and a count such as "3 lines", plus a bar. Tapping a word shows the book title, or "Book", and each line that carries it. "Use [word] on Quotes" closes "Counts" and selects that word on "Quotes". The button is disabled if there is no word.

If counts cannot be read and there are no lines: "Counts failed to load.", the recovery sentence, and "Retry".

### Settings
Title: "Settings". Close is the X.

If there are no books and no lines: "Nothing stored yet." Otherwise a summary such as "2 books, 5 lines, 1 days seated."

"Export" repeats that summary. "Share summary" opens the system share sheet with that same sentence.

"Contact" opens the support page in the browser.

"Show intro again" closes Settings and shows the three intro pages again. Finishing them returns to "Quotes". The library is not cleared.

"Delete library" asks "Delete the library?" with "Books and lines are removed from this device." Buttons: "Delete library" and "Cancel". Confirming removes books, lines, words, seated days, and page progress from this device.

### Apple Watch
The watch app is also named "Chickefrain". It does not edit the phone library. Its usual screen says "Ready", "Weave", and "Seat three lines from three books." A shelf screen titled "Shelf" lists "The Waves", "Middlemarch", and "The Odyssey". A counts screen shows "threshold", "3 lines", and "Days in a row wait until Weave." Those watch lines are fixed on the watch face.

## Features
- Intro pages "Keep the line", "Weave today", and "Reopen the day".
- A shelf of books with title, author, page progress, "On shelf" or "Gone", and "Reread" or "Once".
- "Add a book" and "Add a line", with an optional page and an optional word.
- "Save a word" on a line. The same word on three books makes "Weave" ready.
- "Weave" seats three lines for the day. "Reopen" clears that seating and keeps the word on each line.
- "Days" lists each day as "Empty", "Waiting", "Ready", or "Seated", with "Weave this day" and "Reopen this day".
- "Counts" ranks words by how many lines carry them and shows "days seated in a row". "Use [word] on Quotes" returns to that word.
- "Share summary" shares a sentence of book, line, and seated-day counts.
- "Show intro again" and "Delete library".
- "Contact" opens the support page.

## Behaviours that can look like bugs
- "Save book" stays disabled until "Title" and "Author" are filled and "Pages" is a whole number. Empty pages count as 0 and the book then shows "unknown" until the page total is above 0. Get past it by filling both names. "Pages must be a whole number." appears only for a bad page value.
- "Save line" stays disabled with a blank "Line", with no book, or with a page that is not a whole number. Add a book on "Shelf" when the screen says "Add a book before a line."
- "Save word" stays disabled while "Word" is blank. The stored word is lowercase, and repeated spaces are collapsed. "threshold", "Threshold", and "THRESHOLD" count as the same word.
- "Weave" can be tapped before it is ready. It does not seat lines. The status becomes "Save a word on a line, then tap Weave." or "No word is on three books yet." Put the same word on lines from three different books. Several lines in one book still count as one book. A dot on the word means it is ready.
- "Weave" is disabled, and "Reopen" is enabled, only after today is seated. "Reopen" returns the day to ready so "Weave" works again. The word remains on each line.
- "Quotes" can show "Three lines from three books" before you tap "Weave". Those are the lines that will be seated. After "Weave" the heading becomes "Seated from three books".
- "Days" stays on "No days yet." until the library has a book or a line. After a Weave attempt, that day appears even when it is still "Waiting" and says "No lines saved for this day yet."
- "Counts" stays on "No words counted yet." until a line has a word. It lists at most six words. The streak is 0 until a day has been seated.
- A new shelf says "The shelf is empty." A book with no lines says "No lines in this book yet." "Quotes" says "No shared word yet." and "No lines for this word yet" before the first word and line.
- "Back" or the X, after you have typed, asks "Leave without saving?" Choosing "Keep editing" stays on the form. "Discard" drops what was typed.
- "Mark gone" does not delete the book or its lines. The shelf chip changes to "Gone", and the book screen says "Gone. Lines remain." Lines can still be woven.
- If the saved library cannot be read, the app starts empty and shows "Saved library could not be read. Started from an empty shelf." "Retry" loads it again.
- The watch titles "The Waves", "Middlemarch", "The Odyssey", and "threshold" do not change when the phone library changes.

## Starter content and resume
None on a phone or iPad. The shelf, lines, words, page, "Reread" or "Once", "Gone", and seated days are still there after the app is closed. "Show intro again" does not erase them. "Delete library" does. The watch shows the fixed titles above and does not resume phone edits.

## Permissions
None.

## Absent
Login or accounts, in-app purchase, ads, analytics, user-generated content shared with other people, an account deletion flow, and an App Tracking Transparency prompt are all absent. "Delete library" removes the library on this device only. There is no account to delete.

## Data and support
Books, lines, words, and seated days stay on this device. "Contact" in "Settings" opens the support page. "Share summary" sends only the one-line count sentence through the system share sheet.

## Scanning and health
None.

## Platform
English only. Dates are written as "October 21, 2026". There is no region or language control. Portrait only, on iPhone and iPad, full screen, dark appearance. Minimum iOS version is 17.0. A companion Apple Watch app needs watchOS 26.0 and shows the fixed screens described above.

## Category
Books.
