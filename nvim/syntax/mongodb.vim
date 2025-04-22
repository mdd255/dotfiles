" Vim syntax file
" Language:	MONGODB
" Maintainer:	dungtd10

if !exists("main_syntax")
   if exists("b:current_syntax")
   finish
   endif

   let main_syntax = "mongodb"
elseif exists("b:current_syntax") && b:current_syntax == "mongodb"
  finish
endif

let s:cpo_save = &cpo
set cpo&vim

syn match      mongodbField           "\(\$[a-zA-Z0-9_-]\+\|[a-zA-Z0-9_-]\+:*\)"
syn match      mongodbSubField        "\.[a-zA-Z0-9_]\+"
syn match      mongodbString          "\('\|\"\)[a-zA-Z0-9_]\+\('\|\"\)"
syn match      mongodbKey             "\('\|\"\)[a-zA-Z0-9_]\+\('\|\"\)\s:"
syn match      mongodbKeyword         "\(show\|use\|dbs\|collections\)"
syn match      mongodbNumber          "\s\{1}-*\d\+\.*\d*"
syn match      mongodbBoolean         "\s\{1}\(true\|false\|null\|ISODate\|ObjectId\)"
syn match      mongodbOperator        "[;\=><\(\)\{\}\*\[\],]"
syn match      mongodbQueryOperator   "\(\$eq\|$gt\|$gte\|$in\|$lt\|$lte\|$ne\|$nin\|$and\|$not\|$nor\|$or\|$exists\|$type\|$expr\|$jsonSchema\|$mod\|$regex\|$text\|$where\|$geoIntersects\|$geoWithin\|$near\|$nearSphere\|$all\|$elemMatch\|$size\|$bitsAllClear\|$bitsAllSet\|$bitsAnyClear\|$bitsAnySet\|$elemMatch\|$meta\|$slice\|$comment\|$rand\|$abs\|$add\|$ceil\|$divide\|$exp\|$floor\|$ln\|$log\|$log10\|$mod\|$multiply\|$pow\|$round\|$sqrt\|$subtract\|$trunc\|$arrayElemAt\|$arrayToObject\|$concatArrays\|$filter\|$first\|$in\|$indexOfArray\|$isArray\|$last\|$map\|$objectToArray\|$range\|$reduce\|$reverseArray\|$size\|$slice\|$zip\|$and\|$not\|$or\|$cmp\|$eq\|$gt\|$gte\|$lt\|$lte\|$ne\|$cond\|$ifNull\|$switch\|$accumulator\|$function\|$binarySize\|$bsonSize\|$dateAdd\|$dateDiff\|$dateFromParts\|$dateFromString\|$dateSubtract\|$dateToParts\|$dateToString\|$dateTrunc\|$dayOfMonth\|$dayOfWeek\|$dayOfYear\|$hour\|$isoDayOfWeek\|$isoWeek\|$isoWeekYear\|$millisecond\|$minute\|$month\|$second\|$toDate\|$week\|$year\|$add\|$subtract\|$literal\|$getField\|$rand\|$sampleRate\|$mergeObjects\|$objectToArray\|$setField\|$allElementsTrue\|$anyElementTrue\|$setDifference\|$setEquals\|$setIntersection\|$setIsSubset\|$setUnion\|$concat\|$dateFromString\|$dateToString\|$indexOfBytes\|$indexOfCP\|$ltrim\|$regexFind\|$regexFindAll\|$regexMatch\|$replaceOne\|$replaceAll\|$rtrim\|$split\|$strLenBytes\|$strLenCP\|$strcasecmp\|$substr\|$substrBytes\|$substrCP\|$toLower\|$toString\|$trim\|$toUpper\|$meta\|$sin\|$cos\|$tan\|$asin\|$acos\|$atan\|$atan2\|$asinh\|$acosh\|$atanh\|$sinh\|$cosh\|$tanh\|$degreesToRadians\|$radiansToDegrees\|$convert\|$isNumber\|$toBool\|$toDate\|$toDecimal\|$toDouble\|$toInt\|$toLong\|$toObjectId\|$toString\|$type\|$bucket\|$bucketAuto\|$group\|$accumulator\|$addToSet\|$avg\|$count\|$first\|$last\|$max\|$mergeObjects\|$min\|$push\|$stdDevPop\|$stdDevSamp\|$sum\|$avg\|$max\|$min\|$stdDevPop\|$stdDevSamp\|$sum\|$let\|$addToSet\|$avg\|$count\|$covariancePop\|$covarianceSamp\|$denseRank\|$derivative\|$documentNumber\|$expMovingAvg\|$first\|$integral\|$last\|$max\|$min\|$push\|$rank\|$shift\|$stdDevPop\|$stdDevSamp\|$sum\|$abs\|$accumulator\|$acos\|$acosh\|$add\|$addToSet\|$allElementsTrue\|$and\|$anyElementTrue\|$arrayElemAt\|$arrayToObject\|$asin\|$asinh\|$atan\|$atan2\|$atanh\|$avg\|$binarySize\|$bsonSize\|$ceil\|$cmp\|$concat\|$concatArrays\|$cond\|$convert\|$cos\|$cosh\|$count\|$covariancePop\|$covarianceSamp\|$dateAdd\|$dateDiff\|$dateFromParts\|$dateSubtract\|$dateTrunc\|$dateToParts\|$dateFromString\|$dateToString\|$dayOfMonth\|$dayOfWeek\|$dayOfYear\|$degreesToRadians\|$denseRank\|$derivative\|$divide\|$documentNumber\|$eq\|$exp\|$expMovingAvg\|$filter\|$first\|$first\|$floor\|$function\|$getField\|$gt\|$gte\|$hour\|$ifNull\|$in\|$indexOfArray\|$indexOfBytes\|$indexOfCP\|$integral\|$isArray\|$isNumber\|$isoDayOfWeek\|$isoWeek\|$isoWeekYear\|$last\|$last\|$let\|$literal\|$ln\|$log\|$log10\|$lt\|$lte\|$ltrim\|$map\|$max\|$mergeObjects\|$meta\|$min\|$millisecond\|$minute\|$mod\|$month\|$multiply\|$ne\|$not\|$objectToArray\|$or\|$pow\|$push\|$radiansToDegrees\|$rand\|$range\|$rank\|$reduce\|$regexFind\|$regexFindAll\|$regexMatch\|$replaceOne\|$replaceAll\|$reverseArray\|$round\|$rtrim\|$sampleRate\|$second\|$setDifference\|$setEquals\|$setField\|$setIntersection\|$setIsSubset\|$setUnion\|$shift\|$size\|$sin\|$sinh\|$slice\|$split\|$sqrt\|$stdDevPop\|$stdDevSamp\|$strcasecmp\|$strLenBytes\|$strLenCP\|$substr\|$substrBytes\|$substrCP\|$subtract\|$sum\|$switch\|$tan\|$tanh\|$toBool\|$toDate\|$toDecimal\|$toDouble\|$toInt\|$toLong\|$toObjectId\|$toString\|$toLower\|$toUpper\|$trim\|$trunc\|$type\|$unsetField\|$week\|$year\|$zip\|$group\|$addFields\|$unwind\)\W"

hi def         mongodbKeyword         guifg   =#d38aea  gui=bold,italic
hi def         mongodbQueryOperator   guifg   =#d38aea  gui=italic
hi def         mongodbOperator        guifg   =#deb974  gui=italic
hi def         mongodbField           guifg   =#5dbbc1
hi def         mongodbKey             guifg   =#5dbbc1
hi def         mongodbSubField        guifg   =#deb974
hi def         mongodbBoolean         guifg   =#d38aea
hi def         mongodbNumber          guifg   =#d38aea
hi def link    mongodbString          String

let b:current_syntax = "mongodb"

if main_syntax == "mongodb"
  unlet main_syntax
endif

let &cpo = s:cpo_save
unlet s:cpo_save
