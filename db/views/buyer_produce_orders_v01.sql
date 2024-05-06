SELECT
  o.buyer_id,
  ii.produce_id,
  date_trunc('day', o.created_at) AS order_date,
  LEAD(date_trunc('day', o.created_at)) OVER (
    PARTITION BY o.buyer_id, ii.produce_id
    ORDER BY date_trunc('day', o.created_at)
  ) AS next_order_date
FROM
  orders o
JOIN
  order_details od ON o.id = od.order_id
JOIN
  inventory_items ii ON od.inventory_item_id = ii.id
WHERE
  o.cancelled_at IS NULL
  AND
  ii.quantity > 0;
