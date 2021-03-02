--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid                    ( mappend )
import           Hakyll


--------------------------------------------------------------------------------
main :: IO ()
main = hakyll $ do
  match ("images/*"
         .||.  "files/*"
         .||.  "static/*/*"
         .||. ".well-known/*") $ do
    route idRoute
    compile copyFileCompiler


  match (fromList ["about.md"]) $ do
    route $ setExtension "html"
    compile
      $   pandocCompiler
      >>= loadAndApplyTemplate "templates/page.html"    siteCtx
      >>= loadAndApplyTemplate "templates/default.html" siteCtx
      >>= relativizeUrls

  match "posts/*" $ do
    route $ setExtension "html"
    compile
      $   pandocCompiler
      >>= loadAndApplyTemplate "templates/post.html"    postCtx
      >>= loadAndApplyTemplate "templates/default.html" postCtx
      >>= relativizeUrls

  create ["archive.html"] $ do
    route idRoute
    compile $ do
      posts <- recentFirst =<< loadAll "posts/*"
      let archiveCtx =
            listField "posts" postCtx (return posts)
              `mappend` constField "title" "Archive"
              `mappend` siteCtx

      makeItem ""
        >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
        >>= loadAndApplyTemplate "templates/default.html" archiveCtx
        >>= relativizeUrls

  match "index.md" $ do
    compile $ pandocCompiler

  match "index.html" $ do
    route idRoute
    compile $ do
      posts <- recentFirst =<< loadAll "posts/*"
      let indexCtx =
            listField "posts" postCtx (return posts)
              `mappend` field "index_text" (\_ -> loadBody "index.md")
              `mappend` constField "title" "Anders C. Sørby"
              `mappend` siteCtx
      getResourceBody
        >>= applyAsTemplate indexCtx
        >>= loadAndApplyTemplate "templates/default.html" indexCtx
        >>= relativizeUrls

  match "templates/*" $ compile templateCompiler


--------------------------------------------------------------------------------
postCtx :: Context String
postCtx = dateField "date" "%B %e, %Y" `mappend` siteCtx

siteCtx :: Context String
siteCtx =
  constField "baseurl" ""
    `mappend` constField "site_description" "My homepage"
    `mappend` constField "twitter_username" "anders_sorby"
    `mappend` constField "github_username" "anderssorby"
    `mappend` constField "mastodon_url"  "https://snabelen.no/@anderscs"
    `mappend` constField "header_img"         "sky.jpg"
    `mappend` constField
                "linkedin_url"
                "https://www.linkedin.com/in/anders-christiansen-s%C3%B8rby/"
    `mappend` defaultContext
