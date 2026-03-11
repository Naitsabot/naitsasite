# Standard library imports
from std/options import Option, isSome
from std/tables import toTable
from std/xmltree import escape

# Third-party imports
from db_connector/db_sqlite import DbConn

# Local imports
import ../templates
import ../../utils/db_helpers


proc viewVaultLogin*(notice: string): string =
  var noticeHtml = ""
  if notice.len > 0:
    noticeHtml = notice
  noticeHtml & renderHTMLTemplate("src/web/templates/components/sec-login.html")


proc viewVault*(): string =
  renderHTMLTemplate("src/web/templates/components/sec-vault.html")


proc viewVaultReviews*(db: DbConn, maybeUser: Option[string]): string =
  let rows = getReviews(db)
  var reviewsHtml = ""
  for row in rows:
    reviewsHtml.add "<div class='review'>"
    reviewsHtml.add "<strong>" & escape(row[0]) & "</strong>"
    reviewsHtml.add "<p>" & escape(row[1]) & "</p>"
    reviewsHtml.add "<small>" & escape(row[2]) & "</small>"
    reviewsHtml.add "</div>"
  if reviewsHtml.len == 0:
    reviewsHtml = "<p>No reviews yet. Be the first!</p>"

  let formHtml =
    if maybeUser.isSome:
      """<form action="/api/vault-reviews" method="post" style="margin-bottom:2em;">
        <label for="review-text">Leave a review:</label>
        <textarea id="review-text" name="review_text" rows="4"
          style="width:100%;box-sizing:border-box;padding:0.5em;
                 border:1px solid var(--color-link);border-radius:4px;
                 background:var(--color-bg);color:var(--color-text);
                 font-family:var(--p-font);font-size:var(--p-font-size);"
          required placeholder="Write your review here&hellip;"></textarea>
        <button type="submit" style="margin-top:0.5em;">Submit Review</button>
      </form>"""
    else:
      "<p><a href=\"/vault-login\">Log in</a> to leave a review.</p>"

  renderHTMLTemplate("src/web/templates/components/sec-reviews.html",
    {"reviews": reviewsHtml, "form": formHtml}.toTable)
