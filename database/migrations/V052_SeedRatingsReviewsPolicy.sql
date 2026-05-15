-- V052_SeedRatingsReviewsPolicy.sql
-- Author: Antigravity
-- Date: 2026-05-15
-- Description: Seed Ratings and reviews policy into tblPage
-- Dependencies: V011

SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;

BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM t.tblPage WHERE Slug = 'ratings-and-reviews-policy')
    BEGIN
        INSERT INTO t.tblPage (Title, Slug, Content, MetaTitle, MetaDescription, IsPublished, CreatedBy)
        VALUES (
            'Ratings and reviews policy', 
            'ratings-and-reviews-policy', 
            '<h2>1. Introduction</h2><p>We value customer feedback and are committed to providing a transparent and trustworthy ratings and reviews system for all products sold directly by us or through our Marketplace. This policy sets out our rules and guidelines about the types of ratings and reviews that can be shared. It also explains how we manage ratings and reviews, ensuring authenticity, relevance, fairness, and compliance with consumer protection laws.</p><h2>2. Prohibitions of fake reviews</h2><p>We prohibit the submission of fake ratings or reviews. This includes, but is not limited to:<ul><li>posting or arranging for others to post fake or misleading ratings or reviews</li><li>rating or writing reviews for products you have not purchased or used</li><li>employees or sellers posting ratings and reviews of their own products or competitors'' products.</li></ul>If we determine that a rating or review violates this policy, we reserve the right to remove it and take appropriate action, including suspending accounts or taking legal action.</p><h2>3. Incentivised reviews</h2><p>To maintain transparency, we allow incentivised ratings and reviews only under the following conditions:<ul><li>incentives must be clearly and prominently disclosed within the rating or review</li><li>incentives must not be contingent on a positive rating or review</li><li>ratings or reviews that do not meet these requirements will be removed.</li></ul></p><h2>4. Moderation and publication of ratings and reviews</h2><p>We strive to present ratings and reviews fairly and accurately. Customers can expect:<ul><li>ratings and reviews to be displayed in an unbiased manner</li><li>no artificial weighting or suppression of negative ratings or reviews</li><li>the ability to report suspicious or inappropriate ratings or reviews.</li></ul>We proactively monitor our reviews and prevent the publication of any reviews that do not meet our ratings and reviews guidelines. Here are some examples of reviews which are not permitted:<ul><li>suggestions or examples of violence to children, child pornography, serious injury, or death of a child or adult</li><li>offensive, profane, illicit, or inappropriate comments</li><li>reviews containing personally identifiable information</li><li>reviews containing websites, hyperlinks, or URLs that do not belong to our website</li><li>reviews that are irrelevant to the product or based on guessing/hearsay without actual purchase or experience</li><li>reviews containing contradicting comments or ratings that do not correspond with the sentiment expressed in the review</li><li>reviews that appear to be copied/pasted from another source online or are determined to be fraudulent.</li></ul>We may contact you at the e-mail address attached to your account to request a review or to notify you about the status of your review. Ratings and reviews will generally be published within 2 to 4 business days.</p><h2>5. Submitting a review</h2><p>Customers can submit ratings or reviews through our website or mobile application. You agree that you will not submit a rating or review that:<ul><li>is false, inaccurate or misleading. Your ratings or reviews should be based on your genuine experience with the product</li><li>conceals any incentivisation you may have received in relation to the product (including products provided free of charge)</li><li>has been copied from anyone else or infringes on any third party’s copyright, patent, trademark, trade secret, or other proprietary rights or rights of publicity or privacy</li><li>violates any law or is considered to be offensive, e.g., threatening, libellous, or racially or religiously biased</li><li>includes personal information</li><li>contains any computer viruses, worms, or other potentially damaging computer programs or files</li><li>is otherwise in breach of this policy.</li></ul>By submitting a rating or review, you further agree that:<ul><li>you are the sole author of and are personally responsible for any rating or review you submit and you own any intellectual property rights that relate to it</li><li>all ''moral rights'' that you may have in such content have been voluntarily waived by you.</li></ul></p><h2>6. Handling complaints and negative reviews</h2><p>We do not:<ul><li>encourage customers to submit a complaint instead of leaving a rating or review</li><li>dissuade customers from leaving a rating or review after resolving their complaint</li><li>treat negative ratings or reviews as complaints and prevent them from being published.</li></ul>All ratings or reviews, whether positive or negative, are treated equally and published in accordance with this policy, provided they comply with our ratings and reviews guidelines described in section 4 above. If you have an issue with a product, please get in touch with our customer service team or your Marketplace seller, so that your issue can be addressed promptly.</p><h2>7. Reporting concerns</h2><p>If you believe a rating or review violates our policy, you can report it through the report button directly below each review. We investigate reported ratings or reviews and take appropriate action where necessary. By submitting a rating or review on our platform, you agree to abide by this policy. We reserve the right to update this policy as needed to ensure compliance with consumer protection regulations and maintain the integrity of our ratings and reviews system.</p>',
            'Ratings and reviews policy | Tesco',
            'Read our ratings and reviews policy to understand how we manage customer feedback.',
            1,
            1
        );
        PRINT 'Ratings and reviews policy seeded into tblPage.';
    END

    IF NOT EXISTS (SELECT 1 FROM t.tblMigration WHERE Version = 'V052')
        INSERT INTO t.tblMigration (Version, Description) VALUES ('V052', 'SeedRatingsReviewsPolicy');

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();
    RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
END CATCH
