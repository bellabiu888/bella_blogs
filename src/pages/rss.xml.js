import rss from '@astrojs/rss';
import { getCollection } from 'astro:content';

export async function GET(context) {
  const posts = await getCollection('blog', ({ data }) => !data.draft);
  return rss({
    title: "Bella's Blog",
    description: '记录技术、生活与一路上的思考',
    site: new URL(`${import.meta.env.BASE_URL}/`, context.site),
    items: posts.map((post) => ({ ...post.data, link: `posts/${post.id}/` })),
  });
}
