-- https://platform.stratascratch.com/coding/9814-counting-instances-in-text/official-solution?code_type=1

-- Counting Instances in Text

SELECT 
    word,nentry                                       
FROM  
    ts_stat('SELECT to_tsvector(contents) FROM google_file_store') 
WHERE
         ILIKE 'bull' or word ILIKE 'bear'

