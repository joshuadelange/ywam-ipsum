/* global $, d3 */
$(document).ready(function(){

  var wordsArray = [],
      fill = d3.scale.category20() ;

  $('.top-words .word').each(function(){
    wordsArray.push({
      text: $(this).find('.word-text').html(),
      size: parseInt($(this).find('.word-count').html(), 10) / 50
    }) ;
  }) ;

  $('.top-words ul').remove() ;

  console.log(wordsArray) ;

  function draw(words) {
    console.log('drawing', wordsArray) ;

    d3.select('.top-words').append('svg')
      .attr('width', 900)
      .attr('height', 300)
      .append('g')
      .attr('transform', 'translate(450,150)')
      .selectAll('text')
      .data(wordsArray)
      .enter().append('text')
      .style('font-size', function(d) { return d.size + 'px'; })
      .style('font-family', 'Impact')
      .style('fill', function(d, i) { return fill(i); })
      .attr('text-anchor', 'middle')
      .attr('transform', function(d) {
        return 'translate(' + [d.x, d.y] + ')rotate(' + d.rotate + ')';
      })
      .text(function(d) { return d.text; });
  }

  d3.layout.cloud()
    .size([900, 300])
    .words(wordsArray)
    .padding(2)
    .rotate(function() { return ~~(Math.random() * 2) * 90; })
    .font('Impact')
    .fontSize(function(d) { return d.size; })
    .on('end', draw)
    .start();

}) ;