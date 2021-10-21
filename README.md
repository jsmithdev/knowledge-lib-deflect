# Knowledge Library & Case Deflector

Article View / Defection: tree view of Questions to deflect case creation with tracking, voting and case creation

Knowledge Library: tree view of categories to filter articles with search filtering, pagination, sorting, etc

![Screenshot of Components](https://raw.githubusercontent.com/jsmithdev/knowledge-lib-deflect/master/resources/screenie-both.png "Screenshot of Components")

Article View / Defection: example of article modal when drilled down to & clicking a green highlighted article title

![Screenshot of Components](https://raw.githubusercontent.com/jsmithdev/knowledge-lib-deflect/master/resources/screenie-modal.png "Screenshot of Components")

## component layout

- article-view

  - article-lines
    - article-line
      - modal
        - |- view article
        - |- create case
        - |- vote if helpful/not helpful
    - article-line
      - article-lines
        - article-line
        - article-line
          - ∞

## Notes

These two are being open sourced together since they are so similar, use the same apex class, etc.

However, it may be the case that one is needed and the other not. In that case, I'd deploy all to dev sandbox, demo both, and then deploy one wanted to production or next org in your pipeline.

## Deploy

Covert with SFDX; This creates a folder called `deploy`

```bash
sfdx force:source:convert -r force-app -d deploy
```

Now you can deploy from the resulting `deploy` directory

📌  Below deploys to the default org set; Add `-u user@domain.com` or `-u alias` to deploy else where or -r ArticleTest if test needs ran

```bash
sfdx force:mdapi:deploy -d deploy -w -1  -l NoTestRun --verbose
```

To deploy and run tests, use the `-r ArticleTest`, for example:

```bash
sfdx force:mdapi:deploy -d deploy -w -1 -l RunSpecifiedTests -r ArticleTest --verbose 
```

Results should more or less mirror below

```bash
Using specified username user@example.com

Job ID | 0Af1M000006NHmwSAG
MDAPI PROGRESS | ████████████████████████████████████████ | 22/22 Components
=== Components Deployed [13]
TYPE                      FILE                            NAME               ID
────────────────────────  ──────────────────────────────  ─────────────────  ──────────────────
                          deploy/package.xml              package.xml
ApexClass                 deploy/classes/Article.cls      Article            01p1M000004oT3uQAE
ApexClass                 deploy/classes/ArticleTest.cls  ArticleTest        01p1M000004oT3vQAE
LightningComponentBundle  deploy/lwc/articleCategories    articleCategories  0Rb1M00000001H3SAI
LightningComponentBundle  deploy/lwc/articleCategory      articleCategory    0Rb1M00000001H4SAI
LightningComponentBundle  deploy/lwc/articleLibrary       articleLibrary     0Rb1M00000001H5SAI
LightningComponentBundle  deploy/lwc/articleLine          articleLine        0Rb1M00000001CNSAY
LightningComponentBundle  deploy/lwc/articleLines         articleLines       0Rb1M00000001COSAY
LightningComponentBundle  deploy/lwc/articles             articles           0Rb1M00000001H6SAI
LightningComponentBundle  deploy/lwc/articleView          articleView        0Rb1M00000001CPSAY
LightningComponentBundle  deploy/lwc/modal                modal              0Rb1M00000001CQSAY
LightningComponentBundle  deploy/lwc/paginator            paginator          0Rb1M00000001H7SAI
LightningComponentBundle  deploy/lwc/rummageBar           rummageBar         0Rb1M00000001H8SAI
LightningComponentBundle  deploy/lwc/votingThumbs         votingThumbs       0Rb1M00000001CRSAY

=== Test Success [9]
NAME         METHOD
───────────  ────────────────────
ArticleTest  contentTest
ArticleTest  contentTest2
ArticleTest  dataTests
ArticleTest  dev_count
ArticleTest  getAllArticles
ArticleTest  getAllDataCategories
ArticleTest  getChildQuestions
ArticleTest  getTopLevelQuestions
ArticleTest  searchArticles

=== Apex Code Coverage
NAME     % COVERED  UNCOVERED LINES
───────  ─────────  ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
Article  83%        381,395,396,397,398,399,470,471,478,479,481,483,485,489,491,504,505,506,507,508,514,515,518,519,520,524,526,528,530,531,533,535,537

Total Test Time:  5494.0
```

---

Coded while warming feet under a 🐶 by [Jamie Smith](https://jsmith.dev)
